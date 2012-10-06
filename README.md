Simple (but great) Blog with Nodejs, Express, Mongoose, Markdown and Coffeescript

*** Features ****
- Use Markdown syntax to write your posts
- Simple Administration Interface
- Search mechanism
- Contact form
- Ready to deploy in Heroku

*** Demo ***
To see a demo in action visit [http://app.guidefreitas.com](http://app.guidefreitas.com)

*** Configuration ***
To configure your blog copy config.coffee.sample file to config.coffee and edit:

   exports.dbUrl = 'mongodb://user:pass@host:port/database'
   exports.blog_title = 'Sample Title'
   exports.blog_description = 'Sample Blog Description'
   exports.feed_url = 'http://blogurl.com/rss.xml'
   exports.site_url = 'http://blogurl.com'
   exports.site_image_url = 'http://blogurl.com/icon.png'
   exports.site_author = 'Blogs Author Name'

   exports.author_email = 'blog@authorname.com'
   exports.author_facebook_url = 'https://www.facebook.com/author'
   exports.author_twitter_url = 'http://twitter.com/author'
   exports.author_linkedin_url = 'http://www.linkedin.com/pub/author_url'
   exports.author_github_url = 'https://github.com/author'
   exports.author_skype_url = 'callto://skype_author_username'

*** TODO ***
- Media management in administration interface