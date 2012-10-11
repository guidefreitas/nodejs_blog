mongoose = require('mongoose')
config = require('./config')
config.dbUrl = 'mongodb://localhost:27017/blog_test'

db = mongoose.createConnection(config.dbUrl)
exports.db = db
exports.ObjectId = (id) ->
	new mongoose.Types.ObjectId(id)

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

messageSchema = mongoose.Schema({ 
	name: String,
	email: String, 
	body: String,
	date: Date 
})

User = db.model('User', userSchema)
Post = db.model('Post', postSchema)
Message = db.model('Message', messageSchema)

exports.Post = Post
exports.User = User
exports.Message = Message

User.find({username: 'admin'}, (err, users) ->
	if(!err && users.length == 0)
		gui = new User({ 
			username: 'admin', 
			password: 'admin123', 
			email: 'admin@admin.com',
			admin: true
		})
		gui.save((err) ->
			if(err)
				console.log('Erro ao salvar usuario admin')
		)
)

#UTILS
exports.TrimStr = (str) ->
	return str.replace(/^\s+|\s+$/g,"")

exports.doDashes = (str) ->
	return str.replace(/[^a-z0-9]+/gi, '-').replace(/^-*|-*$/g, '').toLowerCase();
