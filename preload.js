var coffee = require('coffee-script');
var fs = require('fs');

fs.readFile('./app.coffee', function (err, data) {
  if (err) throw err;
  console.log(data);
  coffee.run(data);
});


