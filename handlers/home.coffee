async = require('async')
core = require('../blog_core')
_ = require('underscore')._

exports.index = (req, res) ->
  categories = []
  posts = []
  async.series({
    categories: (callback) ->
      core.Post.find().select('tags').exec((err, tags) ->
        if tags
          filtered_tags = []
          _.each(tags, (tag) ->
            if tag.tags != undefined
              _.each(tag.tags.split(','), (tag2) ->
                tag2 = core.TrimStr(tag2)
                if !_.contains(filtered_tags, tag2)
                  filtered_tags.push(tag2)
              )   
          )
          callback(null,filtered_tags.sort())
      ) 
    ,
    posts: (callback) ->
      core.Post.find().sort('-date').limit(10).exec((err,posts) ->
        callback(null,posts)
      )

  }, 
  (err, results) ->
    if !err
      res.render('blog/index', { pageTitle: 'Guilherme Defreitas', posts: results.posts, layout: 'layout', categories: results.categories})
    else
      res.render('blog/index', { pageTitle: 'OOOOps', posts: []})
  )
