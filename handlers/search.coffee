core = require('../blog_core')

exports.index = (req, res) ->

  tag = req.query["tag"]
  if(tag)
    query = new RegExp(tag, 'i')
    core.Post.where('tags', query).sort('-date').exec((err,posts) ->
      if(err)
        res.render('500', { pageTitle: 'Oops' })
      else
        res.render('blog/search', { pageTitle: 'Busca', posts: posts })
    )
  else
    query = new RegExp(req.query["q"], 'i')
  
    core.Post.find({ $or : [ { title : query } , { body : query } ] }).sort('-date').exec((err, posts) ->
      if(err)
        res.render('500', { pageTitle: 'Oops' })
      else
        res.render('blog/search', { pageTitle: 'Busca', posts: posts })
    )