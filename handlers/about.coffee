core = require('../blog_core')

exports.index = (req,res) ->
  res.render('contact/index', { pageTitle: 'Contact' })

exports.new_message = (req,res) ->
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