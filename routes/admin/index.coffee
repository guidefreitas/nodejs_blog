exports.index = (req,res) ->
  res.render('admin/index', { pageTitle: 'Admin', layout: 'admin_layout'})