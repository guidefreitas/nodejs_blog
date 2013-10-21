core = require('../../blog_core')

exports.index = (req,res) ->
  res.render('admin/media/index', { pageTitle: 'Media' })