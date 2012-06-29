core = require('./blog_core')
express = require('express')

app = express.createServer()

app.use require('connect-assets')()
app.use(express.static(__dirname + '/public'))
app.set('view engine', 'jade')


app.get('/', (req, res) ->
	core.sayHello()
	res.render('index', { pageTitle: 'Guilherme Defreitas Juraszek - Blog' })
)

app.get('/about', (req,res) ->
	res.send('About')
)

app.get('/quale_operadora', (req,res) ->
	res.send('Quale')
);

app.listen(3000)
console.log('Server running at http://0.0.0.0:3000/')