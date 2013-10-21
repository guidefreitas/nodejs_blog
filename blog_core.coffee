mongoose = require('mongoose')
crypto = require('crypto')
config = require('./config')
_ = require('underscore')._
async = require("async")

#UTILS

TrimStr = (str) ->
	return str.replace(/^\s+|\s+$/g,"")

exports.TrimStr = TrimStr
	

exports.doDashes = (str) ->
	return str.replace(/[^a-z0-9]+/gi, '-').replace(/^-*|-*$/g, '').toLowerCase();

db = mongoose.createConnection(config.dbUrl)
exports.config = config
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

projectSchema = mongoose.Schema({
	name: String,
	description: String,
	project_image_url: String,
	website_link: String,
	download_link: String,
	ios_app_store_link: String,
	mac_app_store_link: String,
	marketplace_link: String,
	google_play_link: String
	})

User = db.model('User', userSchema)
Post = db.model('Post', postSchema)
Message = db.model('Message', messageSchema)
Project = db.model('Project', projectSchema)

exports.Post = Post
exports.User = User
exports.Message = Message
exports.Project = Project

exports.PostsTags = () ->
	Post.find().select('tags').exec((err, tags) ->
		if tags
			filtered_tags = []
			_.each(tags, (tag) ->
				if tag.tags != undefined
					_.each(tag.tags.split(','), (tag2) ->
						tag2 = TrimStr(tag2)
						if !_.contains(filtered_tags, tag2.toUpperCase())
							filtered_tags.push(tag2.toUpperCase())
					)		
			)
			return filtered_tags
	)
	

User.find({username: 'admin'}, (err, users) ->
	if(!err && users.length == 0)
		pass_crypted = crypto.createHmac("md5", config.crypto_key).update('admin123').digest("hex")
		gui = new User({ 
			username: 'admin', 
			password: pass_crypted, 
			email: 'admin@admin.com',
			admin: true
		})
		gui.save((err) ->
			if(err)
				console.log('Error when try to save admin user')
		)
)


