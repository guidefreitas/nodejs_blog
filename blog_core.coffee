mongoose = require('mongoose')
config = require('./config')

remoteDbUrl = 'mongodb://heroku:5bw313@alex.mongohq.com:10085/app5635522'
localDbUrl = 'mongodb://localhost/blog'

db = mongoose.createConnection(remoteDbUrl)
exports.db = db
exports.ObjectId = (id) ->
	new mongoose.Types.ObjectId(id)


exports.doDashes = (str) ->
	return str.replace(/[^a-z0-9]+/gi, '-').replace(/^-*|-*$/g, '').toLowerCase();

userSchema = mongoose.Schema({ 
	username: {
		type: String,
		index: {unique: true}
	},
	password: String, 
	email: {
		type: String,
		index: {unique: true}
	},
	admin: Boolean 
})

userSchema.methods.sayHello = () ->
	console.log('HELOOO')

postSchema = mongoose.Schema({ 
	urlid: {
		type: String,
		index: {unique: true}
		},
	title: String, 
	body: String,
	tags: String,
	date: Date 
})

User = db.model('User', userSchema)
Post = db.model('Post', postSchema)

exports.Post = Post
exports.User = User

User.find({username: 'guilherme'}, (err, users) ->
	if(!err && users.length == 0)
		gui = new User({ 
			username: 'guilherme', 
			password: 'gui123', 
			email: 'guilherme.defreitas@gmail.com',
			admin: true
		})
		gui.save((err) ->
			if(err)
				console.log('Erro ao salvar usuario guilherme')
		)
)


#databaseUrl = config.db_database; #"username:password@example.com/mydb"
#collections = ["users", "posts"]
#db = require("mongojs").connect(databaseUrl, collections)



exports.findPosts = () ->
	Post.find().exec((err,posts) ->
		if(err)
			console.log "Erro:" + err
		else
			return posts
	)

exports.findUsers = (args) ->
	args = Array.prototype.slice.call(arguments)
	callback = args.pop()

	User.find(args, (err,users) ->
		callback(err, users)
	)

exports.findOneUser = (args, callback) ->

	User.findOne(args, (err, user) ->
		callback(err, user)
	)

#UTILS
exports.TrimStr = (str) ->
	return str.replace(/^\s+|\s+$/g,"")
