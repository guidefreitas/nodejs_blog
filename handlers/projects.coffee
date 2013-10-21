core = require('../blog_core')

exports.index = (req, res) ->
  core.Project.find().sort('name').exec((err,projects) ->
    if(!err)
      res.render('projects/index', { pageTitle: 'Projects', projects: projects})
    else
      res.render('500', { pageTitle: 'Oops'})
  )