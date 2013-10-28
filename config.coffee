# To set the environment variable on heroku use: 
# heroku config:add DBURL=mongodb://user:pass@host:port/database

exports.dbUrl = process.env['MONGOHQ_URL'] # OR 'mongodb://user:pass@host:port/database'
exports.blog_title = 'Guilherme Defreitas'
exports.blog_description = 'Guilherme Defreitas Blog'
exports.feed_url = 'http://guidefreitas.com/rss.xml'
exports.site_url = 'http://guidefreitas.com'
exports.site_image_url = 'http://guidefreitas.com/icon.png'
exports.site_author = 'Guilherme Defreitas Juraszek'

exports.author_email = 'guilherme.defreitas@gmail.com'
exports.author_facebook_url = 'https://www.facebook.com/guidefreitas'
exports.author_twitter_url = 'http://twitter.com/guidef'
exports.author_linkedin_url = 'http://www.linkedin.com/pub/guilherme-defreitas-juraszek/24/331/2a3'
exports.author_github_url = 'https://github.com/guidefreitas'
exports.author_skype_url = 'callto://guilherme.defreitas'
exports.author_bio_description = 'Bacharel em Sistemas de Informação, com especialização em Engenharia de Software e Mestrando em Computação Aplicada na Universidade do Estado de Santa Catarina (UDESC).'

exports.crypto_key = 'e981739hdkdfasdfknasdfiu9823oa0sdf9023o4f'
exports.locale = 'pt-br'
exports.theme = 'default'