core = require('./blog_core')
express = require('express')
ghm = require('marked')
moment = require('moment')
gzippo = require('gzippo')
_ = require('underscore')._
i18n = require('i18n')
async = require('async')
app = express()

MemStore = express.session.MemoryStore
# NODEJS MIDDLEWARES
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(express.session({ secret: core.config.crypto_key }));

app.use require('connect-assets')()
app.use(express.static('./public'))
app.use(express.responseTime())
#app.use(gzippo.staticGzip(__dirname + '/public'))
app.set('view engine', 'jade')
app.set('views', './views')
app.use(gzippo.compress())
app.use(express.session({
  secret: core.config.crypto_key, 
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
i18n.setLocale(core.config.locale)
moment.lang(core.config.locale);

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
  res.locals.pageTitle = core.config.blog_title
  res.locals.config = core.config
  res.locals.__i = i18n.__
  res.locals.__n = i18n.__n
  next()
);

isAuthenticated = (req, res, next) ->
  if !req.session.userid
    res.redirect('/login')
    return false
  return true

isAdmin = (req, res, next) ->
  if isAuthenticated(req,res,next)
    core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
      if !err and user
        if user.admin 
          next()
      else
        next(new Error('Unauthorized'))
    )

# Routes
routes = require('./routes')
search = require('./routes/search')
rss = require('./routes/rss')
posts = require('./routes/posts')
about = require('./routes/about')
projects = require('./routes/projects')
session = require('./routes/session')
admin = require('./routes/admin')
admin_media = require('./routes/admin/media')
admin_projects = require('./routes/admin/projects')
admin_posts = require('./routes/admin/posts')
admin_messages = require('./routes/admin/messages')

app.use(app.router)

app.get('/', routes.index)
app.get('/search', search.index)
app.get('/rss.xml', rss.index)
app.get('/about', about.index)
app.post('/about/message', about.new_message)
app.get('/projects', projects.index)
app.get('/login', session.login)
app.get('/logout', session.logout)
app.post('/login', session.create_session)
app.get('/admin', isAdmin, admin.index)
app.get('/admin/media', isAdmin, admin_media.index)
app.get('/admin/projects', isAdmin, admin_projects.index)
app.get('/admin/projects/new', isAdmin, admin_projects.new_project)
app.post('/admin/projects', isAdmin, admin_projects.create_project)
app.get('/admin/projects/:id', isAdmin, admin_projects.show_project)
app.get('/admin/projects/edit/:id', isAdmin, admin_projects.edit_project)
app.put('/admin/projects/:id', isAdmin, admin_projects.update_project)
app.del('/admin/projects/:id', isAdmin, admin_projects.remove_project)
app.get('/admin/posts', isAdmin, admin_posts.index)
app.get('/admin/posts/new', isAdmin, admin_posts.new_post)
app.post('/admin/posts', isAdmin, admin_posts.create_post)
app.get('/admin/posts/:id', isAdmin, admin_posts.show_post)
app.get('/admin/posts/edit/:id', isAdmin, admin_posts.edit_post)
app.put('/admin/posts/:id', isAdmin, admin_posts.update_post)
app.del('/admin/posts/:id', isAdmin, admin_posts.remove_post)
app.get('/admin/messages', isAdmin, admin_messages.index)
app.get('/:id', posts.show_post)

app.get('*', (req, res) ->
  res.redirect('/')
);

port = process.env.PORT || 3000;
app.listen(port)
console.log('Server running at http://0.0.0.0:3000/')