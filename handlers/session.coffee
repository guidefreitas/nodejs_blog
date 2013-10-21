core = require('../blog_core')
crypto = require('crypto')

exports.login = (req,res) ->
  req.session.userid = null
  res.render('sessions/new', { pageTitle: 'Login', notice: '' })

exports.logout = (req,res) ->
  req.session.userid = null
  res.redirect('/');

exports.create_session = (req,res) ->
  core.User.findOne({username : req.body.user.username}, (err, user) ->
    if !err and user
      pass_crypted = crypto.createHmac("md5", core.config.crypto_key).update(req.body.user.password).digest("hex")
      if user.password == pass_crypted
        req.session.userid = user._id
        res.redirect('/admin')
      else
        res.render('sessions/new', { pageTitle: 'Admin', notice: 'Invalir user or password' })
    else
      res.render('sessions/new', { pageTitle: 'Admin', notice: 'User not found' })
  )