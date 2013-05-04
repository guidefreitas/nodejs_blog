core = require('./blog_core')
express = require('express')
MemStore = express.session.MemoryStore
ghm = require("marked")
moment = require('moment')
RSS = require('rss')
gzippo = require('gzippo')
crypto = require('crypto')
config = require('./config')
_ = require('underscore')._
i18n = require("i18n")
async = require("async")
app = express();

# NODEJS MIDDLEWARES
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(express.session({ secret: config.crypto_key }));

app.use require('connect-assets')()
#app.use(express.static(__dirname + '/public'))
app.use(gzippo.staticGzip(__dirname + '/public'))
app.set('view engine', 'jade')
app.use(gzippo.compress())
app.use(express.session({
  secret: config.crypto_key, 
  store: MemStore({
    reapInterval: 60000 * 10
  })
}))

#i18n
i18n.configure({
    #setup some locales - other locales default to en silently
    locales:['pt-br', 'en'],

    #where to register __() and __n() to, might be "global" if you know what you are doing
    register: global
})

#SET SYSTEM LANGUAGE
i18n.setLocale('pt-br')
moment.lang('pt-br');

app.configure('production', () ->
  oneYear = 86400
  app.use(express.static(__dirname + '/public', { maxAge: oneYear }))
  app.use(express.errorHandler())
);



currentUser = (req, res, callback) ->
  if !req.session || !req.session.userid
    return null
  else
    core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
      callback(err, user)
    )

app.use((req, res, next) ->
  res.locals.req = req
  res.locals.session = () ->
    if req.session
      return req.session

  res.locals.token = () ->
    if req.session && req.session._csrf
      return req.session._csrf

  res.locals.currentUser = currentUser
  res.locals.notice = false
  res.locals.md = ghm
  res.locals.moment = moment
  res.locals.TrimStr = core.TrimStr
  res.locals.pageTitle = config.blog_title
  res.locals.config = config
  res.locals.__i = i18n.__
  res.locals.__n = i18n.__n
  next()
);


## END HELPERS

isAuthenticated = (req, res, next) ->
  if !req.session.userid
    res.redirect('/login')
    return false
  return true

andIsAdmin = (req, res, next) ->
  if isAuthenticated(req,res,next)
    core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
      if !err and user
        if user.admin 
          next()
      else
        next(new Error('Unauthorized'))
    )


app.get('/', (req, res) ->
  categories = []
  posts = []
  async.series({
    categories: (callback) ->
      core.Post.find().select('tags').exec((err, tags) ->
        if tags
          filtered_tags = []
          _.each(tags, (tag) ->
            if tag.tags != undefined
              _.each(tag.tags.split(','), (tag2) ->
                tag2 = core.TrimStr(tag2)
                if !_.contains(filtered_tags, tag2)
                  filtered_tags.push(tag2)
              )   
          )
          callback(null,filtered_tags.sort())
      ) 
    ,
    posts: (callback) ->
      core.Post.find().sort('-date').limit(10).exec((err,posts) ->
        callback(null,posts)
      )

  }, 
  (err, results) ->
    if !err
      res.render('blog/index', { pageTitle: 'Guilherme Defreitas', posts: results.posts, layout: 'layout', categories: results.categories})
    else
      res.render('blog/index', { pageTitle: 'OOOOps', posts: []})
  )
)

app.get('/page/:id' , (req,res) ->
  id = parseInt(req.params.id)
  async.series({
    categories: (callback) ->
      core.Post.find().select('tags').exec((err, tags) ->
        if tags
          filtered_tags = []
          _.each(tags, (tag) ->
            if tag.tags != undefined
              _.each(tag.tags.split(','), (tag2) ->
                tag2 = core.TrimStr(tag2)
                if !_.contains(filtered_tags, tag2)
                  filtered_tags.push(tag2)
              )   
          )
          callback(null,filtered_tags.sort())
      ) 
    ,
    posts: (callback) ->
      core.Post.find().sort('-date').skip((id-1)*10).limit(10).exec((err,posts) ->
        callback(null,posts)
      )

  }, 
  (err, results) ->
    if !err
      res.render('blog/index', { pageTitle: 'Guilherme Defreitas', posts: results.posts, categories: results.categories})
    else
      res.render('blog/index', { pageTitle: 'OOOOps', posts: []})
  )
)

app.get('/posts_home', (req, res) ->
  from = req.query["from"]
  if(!from)
    res.json(['FAIL - Parameter from not informed'])

  core.Post.find().sort('-date').skip(from).limit(5).exec((err,posts) ->
    if(!err)
      posts_render = []
      count = 0
      while count<posts.length
        post = posts[count]
        post_render = {
          title: post.title,
          body: ghm.parse(post.body),
          date: moment(post.date).format('LL')
          tags: post.tags,
          urlid: post.urlid
        }
        posts_render.push(post_render)
        count++
      res.json(posts_render)  
    else
      res.json(['FAIL'])
  )
)

app.get('/search',(req, res) ->

  tag = req.query["tag"]
  if(tag)
    query = new RegExp(tag, 'i')
    core.Post.where('tags', query).sort('-date').exec((err,posts) ->
      if(err)
        res.render('500', { pageTitle: 'Oops' })
      else
        res.render('blog/search', { pageTitle: 'Busca', posts: posts })
    )
  else
    query = new RegExp(req.query["q"], 'i')
  
    core.Post.find({ $or : [ { title : query } , { body : query } ] }).sort('-date').exec((err, posts) ->
      if(err)
        res.render('500', { pageTitle: 'Oops' })
      else
        res.render('blog/search', { pageTitle: 'Busca', posts: posts })
    )
)

app.get('/rss.xml', (req, res) ->
  

  feed = new RSS({
        title: config.blog_title,
        description: config.blog_description,
        feed_url: config.feed_url,
        site_url: config.site_url,
        image_url: config.site_image_url,
        author: config.site_author
    })

  core.Post.find().exec((err,posts) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    else
      posts.map (post) ->
        feed.item({
                title:  post.title,
                url: config.site_url + '/' + post.urlid          
            })
          res.contentType("rss")
      res.send(feed.xml());
  )

  
)

app.get('/about', (req,res) ->
  res.render('contact/index', { pageTitle: 'Contact' })
)

app.post('/about/message', (req,res) ->
  name = req.body.name
  email = req.body.email
  body = req.body.message
  message = new core.Message({
    name: name,
    email: email,
    body: body,
    date: new Date()      
  })

  message.save((err) ->
    if(err)
      res.send(500, { error: '' })
    else
      res.json(['OK'])        
  )
)

app.get('/projects', (req, res) ->
  core.Project.find().sort('name').exec((err,projects) ->
    if(!err)
      res.render('projects/index', { pageTitle: 'Projects', projects: projects})
    else
      res.render('500', { pageTitle: 'Oops'})
  )
);

app.get('/admin/media', andIsAdmin, (req,res) ->
  res.render('admin/media/index', { pageTitle: 'Media' })
);


app.get('/login', (req,res) ->
  req.session.userid = null
  res.render('sessions/new', { pageTitle: 'Login', notice: '' })
);

app.get('/logout', (req,res) ->
  req.session.userid = null
  res.redirect('/');
);

app.post('/login', (req,res) ->
  core.User.findOne({username : req.body.user.username}, (err, user) ->
    if !err and user
      pass_crypted = crypto.createHmac("md5", config.crypto_key).update(req.body.user.password).digest("hex")
      if user.password == pass_crypted
        req.session.userid = user._id
        res.redirect('/admin')
      else
        res.render('sessions/new', { pageTitle: 'Admin', notice: 'Invalir user or password' })
    else
      res.render('sessions/new', { pageTitle: 'Admin', notice: 'User not found' })
  )
);

app.get('/admin', andIsAdmin, (req,res) ->

  res.render('admin/index', { pageTitle: 'Admin', layout: 'admin_layout'})
);

app.get('/admin/projects', andIsAdmin, (req, res) ->
  core.Project.find().sort('name').exec((err,projects) ->
    if(!err)
      res.render('admin/projects/index', { pageTitle: 'Projects', layout: 'admin_layout', projects: projects})
    else
      res.render('500', { pageTitle: 'Oops'})
  )
);

app.post('/admin/projects', andIsAdmin, (req, res) ->
  project = new core.Project({
    name: req.body.project.name,
    description: req.body.project.description,
    project_image_url: req.body.project.project_image_url,
    download_link: req.body.project.download_link,
    website_link: req.body.project.website_link,
    ios_app_store_link: req.body.project.ios_app_store_link,
    mac_app_store_link: req.body.project.mac_app_store_link,
    marketplace_link: req.body.project.marketplace_link,
    google_play_link: req.body.project.google_play_link
  })

  project.save((err) ->
    if(err)
      res.render('projects/new', { pageTitle: 'New Project', layout: 'admin_layout', notice: 'Error while saving the project' })
    else
      res.redirect('/admin/projects')
    )
);

app.get('/admin/projects/new', andIsAdmin, (req,res) ->
  project = new core.Project()
  res.render('admin/projects/new', { pageTitle: 'New Project', layout: 'admin_layout', project: project })
);

app.get('/admin/projects/:id', andIsAdmin, (req,res) ->
  core.Project.findOne({_id : core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })
    res.render('admin/projects/show', { pageTitle: 'Project', project: project })
  )
);

app.get('/admin/projects/edit/:id', andIsAdmin, (req,res) ->
  core.Project.findOne({_id : core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })

    res.render('admin/projects/edit', { pageTitle: 'Edit Project', project: project })
  )
);

app.put('/admin/projects/:id', andIsAdmin, (req, res) ->
  core.Project.findOne({_id:core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })

    project.name = req.body.project.name
    project.description = req.body.project.description
    project.project_image_url = req.body.project.project_image_url
    project.download_link = req.body.project.download_link
    project.website_link = req.body.project.website_link
    project.ios_app_store_link = req.body.project.ios_app_store_link
    project.mac_app_store_link = req.body.project.mac_app_store_link
    project.marketplace_link = req.body.project.marketplace_link
    project.google_play_link = req.body.project.google_play_link

    project.save((err) ->
      if(err)
        res.render('admin/projects/edit', { pageTitle: 'Edit Project', project: project})
      else
        res.redirect('admin/projects')
    )
  )
)

app.del('/admin/projects/:id', andIsAdmin, (req, res) ->
  core.Project.findOne({_id : core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })

    project.remove((err) ->
      if(!err)
        res.redirect('/admin/projects')  
    )
  )
)

app.get('/admin/posts', andIsAdmin, (req,res) ->
  core.Post.find().sort('-date').exec((err,posts) ->
    if(!err)
      res.render('admin/posts/index', { pageTitle: 'Posts', layout: 'admin_layout', posts: posts }) 
    else
      res.render('500', { pageTitle: 'Oops' })
  )
);

app.post('/admin/posts', andIsAdmin, (req,res) ->
  title = req.body.post.title
  body = req.body.post.body
  tags = req.body.post.tags
  urlid = core.doDashes(title)

  core.Post.findOne({urlid : urlid}).exec((err, post) ->
    if(post)
      urlid = urlid + '-' + moment().format('DD-MM-YYYY-HH:mm')
    post = new core.Post({
      title: title,
      body: body,
      urlid: urlid,
      tags : tags,
      date: new Date()      
    })

    post.save((err) ->
      if(err)
        res.render('posts/new', { pageTitle: 'New Post', layout: 'admin_layout', notice: 'Error while saving the post' })
      else
        res.redirect('/admin/posts')        
    )
  )
)

app.get('/admin/posts/new', andIsAdmin, (req,res) ->
  post = new core.Post()
  res.render('posts/new', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
);

app.get('/admin/posts/:id', andIsAdmin, (req,res) ->
  core.Post.findOne({_id : core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    res.render('admin/posts/show', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
  )
);

app.put('/admin/posts/:id', andIsAdmin, (req, res) ->
  title = req.body.post.title
  body = req.body.post.body
  tags = req.body.post.tags
  urlid = core.doDashes(title)
  core.Post.findOne({_id:core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    post.title = title
    post.body = body
    post.tags = tags
    post.urlid = urlid
    post.save((err) ->
      if(err)
        res.render('posts/edit', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
      else
        res.redirect('/admin/posts')
    )
  )
)

app.del('/admin/posts/:id', andIsAdmin, (req, res) ->
  core.Post.findOne({_id : core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    post.remove((err) ->
      if(!err)
        res.redirect('/admin/posts')  
    )
  )
)

app.get('/admin/posts/edit/:id', andIsAdmin, (req,res) ->
  core.Post.findOne({_id : core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    res.render('posts/edit', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
  )
);

app.get('/admin/messages', andIsAdmin, (req, res) ->
  core.Message.find().exec((err, messages) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    else
      res.render('admin/messages/index', layout: 'admin_layout', messages:messages)
  )
)

app.get('/:id', (req, res) ->
  urlid = req.params.id
  post = core.Post.findOne({urlid: urlid}).exec((err, post) ->
    if(!err)
      if(post)
        res.render('blog/show', { pageTitle: config.blog_title + " - " + post.title, post: post })      
      else
        res.render('404', { pageTitle: 'Not Found :(' })
    else
      res.render('500', { pageTitle: 'Oops' })    
  )
  
)



app.get('*', (req, res) ->
  #res.render('404', { pageTitle: 'Not Found :(' })
  res.redirect('/')
);

port = process.env.PORT || 3000;
app.listen(port)
console.log('Server running at http://0.0.0.0:3000/')