core = require('../../blog_core')

exports.index = (req,res) ->
  core.Post.find().sort('-date').exec((err,posts) ->
    if(!err)
      res.render('admin/posts/index', { pageTitle: 'Posts', layout: 'admin_layout', posts: posts }) 
    else
      res.render('500', { pageTitle: 'Oops' })
  )

exports.new_post = (req,res) ->
  post = new core.Post()
  res.render('posts/new', { pageTitle: 'New Post', layout: 'admin_layout', post:post })

exports.create_post = (req,res) ->
  title = req.body.post.title
  body = req.body.post.body
  tags = req.body.post.tags
  urlid = core.doDashes(title)

  core.Post.findOne({urlid : urlid}).exec((err, post) ->
    if(post)
      urlid = urlid + '-' + moment().format('DD-MM-YYYY-HH:mm')
    post = new core.Post({
      title: title,
      body: body,
      urlid: urlid,
      tags : tags,
      date: new Date()      
    })

    post.save((err) ->
      if(err)
        res.render('posts/new', { pageTitle: 'New Post', layout: 'admin_layout', notice: 'Error while saving the post' })
      else
        res.redirect('/admin/posts')        
    )
  )

exports.show_post = (req,res) ->
  core.Post.findOne({_id : core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    res.render('admin/posts/show', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
  )

exports.edit_post = (req,res) ->
  core.Post.findOne({_id : core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    res.render('posts/edit', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
  )

exports.update_post = (req, res) ->
  title = req.body.post.title
  body = req.body.post.body
  tags = req.body.post.tags
  urlid = core.doDashes(title)
  core.Post.findOne({_id:core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    post.title = title
    post.body = body
    post.tags = tags
    post.urlid = urlid
    post.save((err) ->
      if(err)
        res.render('posts/edit', { pageTitle: 'New Post', layout: 'admin_layout', post:post })
      else
        res.redirect('/admin/posts')
    )
  )

exports.remove_post = (req, res) ->
  core.Post.findOne({_id : core.ObjectId(req.params.id)}).exec((err,post) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    if(!post)
      res.render('404', { pageTitle: 'Not Found :(' })

    post.remove((err) ->
      if(!err)
        res.redirect('/admin/posts')  
    )
  )