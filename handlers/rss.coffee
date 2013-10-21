RSS = require('rss')
core = require('../blog_core')

exports.index = (req, res) ->
  feed = new RSS({
        title: core.config.blog_title,
        description: core.config.blog_description,
        feed_url: core.config.feed_url,
        site_url: core.config.site_url,
        image_url: core.config.site_image_url,
        author: core.config.site_author
    })
  core.Post.find().exec((err,posts) ->
    if(err)
      res.render('500', { pageTitle: 'Oops' })
    else
      posts.map (post) ->
        feed.item({
                title:  post.title,
                url: core.config.site_url + '/' + post.urlid          
            })
          res.contentType("rss")
      res.send(feed.xml());
  ) 
