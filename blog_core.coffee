cfg = require('./config')

exports.sayHello = () -> console.log('Teste 123')
exports.property = "blue"

databaseUrl = cfg.db_database; #"username:password@example.com/mydb"
collections = ["users", "posts"]
db = require("mongojs").connect(databaseUrl, collections)
exports.db = db


exports.findPosts = () ->
	db.posts.find((err,posts) ->
		if(err || !posts)
			console.log "No users found"
		else
			posts.forEach((post) ->
				console.log(post)
			)
			return posts
	)

exports.findUsers = (args) ->
	args = Array.prototype.slice.call(arguments)
	callback = args.pop()

	db.users.find(args, (err,users) ->
		callback(err, users)
	)

exports.findOneUser = (args, callback) ->

	db.users.findOne(args, (err, user) ->
		callback(err, user)
	)

exports.ObjectId = db.ObjectId
