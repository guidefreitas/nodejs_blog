core = require('../../blog_core')

exports.index = (req, res) ->
  core.Project.find().sort('name').exec((err,projects) ->
    if(!err)
      res.render('admin/projects/index', { pageTitle: 'Projects', layout: 'admin_layout', projects: projects})
    else
      res.render('500', { pageTitle: 'Oops'})
  )

exports.new_project = (req,res) ->
  project = new core.Project()
  res.render('admin/projects/new', { pageTitle: 'New Project', layout: 'admin_layout', project: project })

exports.create_project = (req, res) ->
  project = new core.Project({
    name: req.body.project.name,
    description: req.body.project.description,
    project_image_url: req.body.project.project_image_url,
    download_link: req.body.project.download_link,
    website_link: req.body.project.website_link,
    ios_app_store_link: req.body.project.ios_app_store_link,
    mac_app_store_link: req.body.project.mac_app_store_link,
    marketplace_link: req.body.project.marketplace_link,
    google_play_link: req.body.project.google_play_link
  })

  project.save((err) ->
    if(err)
      res.render('projects/new', { pageTitle: 'New Project', layout: 'admin_layout', notice: 'Error while saving the project' })
    else
      res.redirect('/admin/projects')
    )

exports.show_project = (req,res) ->
  core.Project.findOne({_id : core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })
    res.render('admin/projects/show', { pageTitle: 'Project', project: project })
  )

exports.edit_project = (req,res) ->
  core.Project.findOne({_id : core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })

    res.render('admin/projects/edit', { pageTitle: 'Edit Project', project: project })
  )

exports.update_project = (req, res) ->
  core.Project.findOne({_id:core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })

    project.name = req.body.project.name
    project.description = req.body.project.description
    project.project_image_url = req.body.project.project_image_url
    project.download_link = req.body.project.download_link
    project.website_link = req.body.project.website_link
    project.ios_app_store_link = req.body.project.ios_app_store_link
    project.mac_app_store_link = req.body.project.mac_app_store_link
    project.marketplace_link = req.body.project.marketplace_link
    project.google_play_link = req.body.project.google_play_link

    project.save((err) ->
      if(err)
        res.render('admin/projects/edit', { pageTitle: 'Edit Project', project: project})
      else
        res.redirect('admin/projects')
    )
  )

exports.remove_project = (req, res) ->
  core.Project.findOne({_id : core.ObjectId(req.params.id)}).exec((err,project) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!project)
      res.render('404', { pageTitle: 'Not Found :(' })

    project.remove((err) ->
      if(!err)
        res.redirect('/admin/projects')  
    )
  )