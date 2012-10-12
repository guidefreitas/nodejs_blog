core = require('../blog_core')
assert = require("assert")
core.config.dbUrl = 'mongodb://localhost:27017/blog_test'
describe('User', () ->
	user = new core.User({ 
			username: 'userteste', 
			password: 'userteste', 
			email: 'teste@teste.com',
			admin: false
		})

	describe('#save()', () ->
		it('should not have errors', () ->
			user.save((err) ->
				err.should.equal null
			)
		)
	)

	describe('#findOne()', () ->
		it('should have same username and email', () ->
			core.User.findOne({username : 'userteste'}, (err, user2) -> 
				user2.email.should.equal user1.email
				user2.username.should.equal 'teste'
			)
		)
	)

	describe('#find()', () ->
		it('should have size > 0', () ->
			core.User.find().exec((err,users) ->
				users.should.have.length(1)
			)
		)
	)
)