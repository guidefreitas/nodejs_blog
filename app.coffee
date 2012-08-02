core = require('./blog_core')
express = require('express')


app = express.createServer()

app.use(express.bodyParser());
app.use(express.cookieParser());
app.use(express.session({ secret: "keyboard cat" }));

app.use require('connect-assets')()
app.use(express.static(__dirname + '/public'))
app.set('view engine', 'jade')


currentUser = (req, res, callback) ->
	core.findOneUser({_id : core.ObjectId(req.session.userid)}, (err, user) ->
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

		return core.findOneUser({_id : core.ObjectId(req.session.userid)}, (err, user) ->
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
		core.findOneUser({_id : core.ObjectId(req.session.userid)}, (err, user) ->
			if !err and user
				if user.admin 
					next()
			else
				next(new Error('Unauthorized'))
		)
		



app.get('/', (req, res) ->
	res.render('blog/index', { pageTitle: 'Guilherme Defreitas' })
)

app.get('/blog/:id', (req, res) ->
	res.render('blog/show', { pageTitle: 'Blog' })
)

app.get('/sobre', (req,res) ->
	res.render('contato/index', { pageTitle: 'Contato' })
)

app.get('/aplicativos', (req,res) ->
	res.render('apps/index', { pageTitle: 'Aplicativos' })
);

app.get('/aplicativos/:id', (req,res) ->
	res.render('apps/show', { pageTitle: 'Aplicativos' })
);

app.get('/media', andIsAdmin, (req,res) ->
	res.render('media/index', { pageTitle: 'Media',  layout: 'admin_layout' })
);


app.get('/login', (req,res) ->
	req.session.userid = null
	res.render('sessions/new', { pageTitle: 'Login' })
);

app.get('/logout', (req,res) ->
	req.session.userid = null
	res.redirect('/');
);

app.post('/login', (req,res) ->
	core.findOneUser({username : req.body.user.username}, (err, user) ->
		if !err and user
			if user.password == req.body.user.password
				req.session.userid = user._id;
				res.redirect('/admin');
			else
				console.log 'Usuario ou senha incorretos'
				res.render('sessions/new', { pageTitle: 'Admin' })
		else
			console.log 'Usuario nao encontrado'
			res.render('sessions/new', { pageTitle: 'Admin' })
	)
);

app.get('/admin', andIsAdmin, (req,res) ->
	res.render('admin/index', { pageTitle: 'Admin', layout: 'admin_layout' })
);

app.get('/admin/posts', andIsAdmin, (req,res) ->
	res.render('posts/index', { pageTitle: 'Posts', layout: 'admin_layout' })
);

app.get('/admin/posts/new', andIsAdmin, (req,res) ->
	res.render('posts/new', { pageTitle: 'New Post', layout: 'admin_layout' })
);

app.get('/admin/posts/edit/:id', andIsAdmin, (req,res) ->
	res.render('posts/edit', { pageTitle: 'New Post', layout: 'admin_layout' })
);

app.get('*', (req, res) ->
	res.render('404', { pageTitle: 'Not Found :(' })
);

port = process.env.PORT || 3000;
app.listen(port)
console.log('Server running at http://0.0.0.0:3000/')