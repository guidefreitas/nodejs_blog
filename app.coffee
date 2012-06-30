core = require('./blog_core')
express = require('express')


app = express.createServer()

app.use require('connect-assets')()
app.use(express.static(__dirname + '/public'))
app.set('view engine', 'jade')


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

port = process.env.PORT || 3000;
app.listen(port)
console.log('Server running at http://0.0.0.0:3000/')