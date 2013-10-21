core = require('../blog_core')

exports.show_post = (req, res) ->
  urlid = req.params.id
  post = core.Post.findOne({urlid: urlid}).exec((err, post) ->
    if(!err)
      if(post)
        res.render('blog/show', { pageTitle: core.config.blog_title + " - " + post.title, post: post })      
      else
        res.render('404', { pageTitle: 'Not Found :(' })
    else
      res.render('500', { pageTitle: 'Oops' })    
  )