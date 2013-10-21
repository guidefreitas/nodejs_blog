core = require('../../blog_core')

exports.index = (req, res) ->
  core.Message.find().exec((err, messages) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    else
      res.render('admin/messages/index', layout: 'admin_layout', messages:messages)
  )