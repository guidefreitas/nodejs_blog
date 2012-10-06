core = require('./blog_core')
express = require('express')
ghm = require("github-flavored-markdown")
moment = require('moment')
RSS = require('rss')
gzippo = require('gzippo')
moment.lang('pt-br');

app = express.createServer()

app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(express.session({ secret: "keyboard cat" }));

app.use require('connect-assets')()
#app.use(express.static(__dirname + '/public'))
app.use(gzippo.staticGzip(__dirname + '/public'))
app.set('view engine', 'jade')

app.helpers({ notice: false })
app.helpers({ md: ghm })
app.helpers({moment : moment})
app.helpers({TrimStr : core.TrimStr })
app.helpers({pageTitle : 'Guilherme Defreitas' })
app.dynamicHelpers({
    req: (req, res) ->
        return req
})

# COMPRESS
app.use(gzippo.compress())

## CACHE CONFIG
app.dynamicHelpers({
	req: (req, res) ->
		if (!res.getHeader('Cache-Control'))
			res.setHeader('Cache-Control', 'public, max-age=' + 86400)
			return req
})

app.configure('production', () ->
	oneYear = 86400
	app.use(express.static(__dirname + '/public', { maxAge: oneYear }))
	app.use(express.errorHandler())
);
## END CACHE CONFIG

currentUser = (req, res, callback) ->
	core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
		callback(err, user)
			
	)

app.dynamicHelpers({
  token: (req, res) ->
    return req.session._csrf;
  
});

app.dynamicHelpers({
	current_user: (req, res) ->
		if !req.session.userid
			return null

		return core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
			if !err and user
				return user
		)

})


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
	core.Post.find().sort('-date').exec((err,posts) ->
		if(!err)
			res.render('blog/index', { pageTitle: 'Guilherme Defreitas', posts: posts })	
		else
			res.render('500', { pageTitle: 'Oops' })
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
				res.render('blog/index', { pageTitle: 'Busca', posts: posts })
		)
	else
		query = new RegExp(req.query["q"], 'i')
	
		core.Post.find({ $or : [ { title : query } , { body : query } ] }).sort('-date').exec((err, posts) ->
			if(err)
				res.render('500', { pageTitle: 'Oops' })
			else
				res.render('blog/index', { pageTitle: 'Busca', posts: posts })
		)
)

app.get('/rss.xml', (req, res) ->
	

	feed = new RSS({
        title: 'Guilherme Defreitas Blog',
        description: 'Guilherme Defreitas Blog',
        feed_url: 'http://guidefreitas.com/rss.xml',
        site_url: 'http://guidefreitas.com',
        image_url: 'http://guidefreitas.com/icon.png',
        author: 'Guilherme Defreitas Juraszek'
    })

	core.Post.find().exec((err,posts) ->
		if(err)
			res.render('500', { pageTitle: 'Oops' })
		else
			posts.map (post) ->
				feed.item({
            		title:  post.title,
            		url: 'http://guidefreitas.com/' + post.urlid          
        		})
        	res.contentType("rss")
			res.send(feed.xml());


	)

	
)

app.get('/about', (req,res) ->
	res.render('contato/index', { pageTitle: 'Contato' })
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

app.get('/projects', (req,res) ->
	res.render('projects/index', { pageTitle: 'Aplicativos' })
);

app.get('/media', andIsAdmin, (req,res) ->
	res.render('media/index', { pageTitle: 'Media',  layout: 'admin_layout' })
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
			if user.password == req.body.user.password
				req.session.userid = user._id
				res.redirect('/admin')
			else
				res.render('sessions/new', { pageTitle: 'Admin', notice: 'Usuario ou senha incorretos' })
		else
			res.render('sessions/new', { pageTitle: 'Admin', notice: 'Usuario nao encontrado' })
	)
);

app.get('/admin', andIsAdmin, (req,res) ->

	res.render('admin/index', { pageTitle: 'Admin', layout: 'admin_layout'})
);

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
				res.render('posts/new', { pageTitle: 'New Post', layout: 'admin_layout', notice: 'Erro ao salvar' })
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
				res.render('blog/show', { pageTitle: post.title, post: post })			
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