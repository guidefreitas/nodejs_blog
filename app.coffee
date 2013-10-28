core = require('./blog_core')
express = require('express')
ghm = require('marked')
moment = require('moment')
gzippo = require('gzippo')
_ = require('underscore')._
i18n = require('i18n')
async = require('async')
app = express()

MemStore = express.session.MemoryStore
# NODEJS MIDDLEWARES
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(express.session({ secret: core.config.crypto_key }));

assets_dir = "./themes/" + core.config.theme + "/assets/"
app.use require('connect-assets')(src:assets_dir)
app.use(express.static('./public'))
app.use(express.responseTime())
#app.use(gzippo.staticGzip(__dirname + '/public'))
app.set('view engine', 'jade')
views_dir = "./themes/" + core.config.theme + "/views"
app.set('views', views_dir)
app.use(gzippo.compress())
app.use(express.session({
  secret: core.config.crypto_key, 
  store: MemStore({
    reapInterval: 60000 * 10
  })
}))

#i18n
i18n.configure({
    #setup some locales - other locales default to en silently
    locales:['pt-br', 'en'],

    #where to register __() and __n() to, might be "global" if you know what you are doing
    register: global
})

#SET SYSTEM LANGUAGE
i18n.setLocale(core.config.locale)
moment.lang(core.config.locale);

app.configure('production', () ->
  oneYear = 86400
  app.use(express.static(__dirname + '/public', { maxAge: oneYear }))
  app.use(express.errorHandler())
);

currentUser = (req, res, callback) ->
  if !req.session || !req.session.userid
    return null
  else
    core.User.findOne({_id : core.ObjectId(req.session.userid)}, (err, user) ->
      callback(err, user)
    )

app.use((req, res, next) ->
  res.locals.req = req
  res.locals.session = () ->
    if req.session
      return req.session

  res.locals.token = () ->
    if req.session && req.session._csrf
      return req.session._csrf

  res.locals.currentUser = currentUser
  res.locals.notice = false
  res.locals.md = ghm
  res.locals.moment = moment
  res.locals.TrimStr = core.TrimStr
  res.locals.pageTitle = core.config.blog_title
  res.locals.config = core.config
  res.locals.__i = i18n.__
  res.locals.__n = i18n.__n
  next()
);

app.use(app.router)
routes = require('./routes')(app)

port = process.env.PORT || 3000;
app.listen(port)
console.log('Server running at http://0.0.0.0:3000/')