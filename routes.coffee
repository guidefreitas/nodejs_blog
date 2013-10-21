core = require('./blog_core')

isAuthenticated = (req, res, next) ->
  if !req.session.userid
    res.redirect('/login')
    return false
  return true

isAdmin = (req, res, next) ->
  if isAuthenticated(req,res,next)
    core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
      if !err and user
        if user.admin 
          next()
      else
        next(new Error('Unauthorized'))
    )


home = require('./handlers/home')
search = require('./handlers/search')
rss = require('./handlers/rss')
posts = require('./handlers/posts')
about = require('./handlers/about')
projects = require('./handlers/projects')
session = require('./handlers/session')
admin = require('./handlers/admin')
admin_media = require('./handlers/admin/media')
admin_projects = require('./handlers/admin/projects')
admin_posts = require('./handlers/admin/posts')
admin_messages = require('./handlers/admin/messages')

module.exports = (app) ->
  app.get('/', home.index)
  app.get('/search', search.index)
  app.get('/rss.xml', rss.index)
  app.get('/about', about.index)
  app.post('/about/message', about.new_message)
  app.get('/projects', projects.index)
  app.get('/login', session.login)
  app.get('/logout', session.logout)
  app.post('/login', session.create_session)
  app.get('/admin', isAdmin, admin.index)
  app.get('/admin/media', isAdmin, admin_media.index)
  app.get('/admin/projects', isAdmin, admin_projects.index)
  app.get('/admin/projects/new', isAdmin, admin_projects.new_project)
  app.post('/admin/projects', isAdmin, admin_projects.create_project)
  app.get('/admin/projects/:id', isAdmin, admin_projects.show_project)
  app.get('/admin/projects/edit/:id', isAdmin, admin_projects.edit_project)
  app.put('/admin/projects/:id', isAdmin, admin_projects.update_project)
  app.del('/admin/projects/:id', isAdmin, admin_projects.remove_project)
  app.get('/admin/posts', isAdmin, admin_posts.index)
  app.get('/admin/posts/new', isAdmin, admin_posts.new_post)
  app.post('/admin/posts', isAdmin, admin_posts.create_post)
  app.get('/admin/posts/:id', isAdmin, admin_posts.show_post)
  app.get('/admin/posts/edit/:id', isAdmin, admin_posts.edit_post)
  app.put('/admin/posts/:id', isAdmin, admin_posts.update_post)
  app.del('/admin/posts/:id', isAdmin, admin_posts.remove_post)
  app.get('/admin/messages', isAdmin, admin_messages.index)
  app.get('/:id', posts.show_post)

  app.get('*', (req, res) ->
    res.redirect('/')
  )