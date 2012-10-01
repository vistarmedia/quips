var fs   = require('fs-extra');
var argv = process.argv.slice(2);
fs.copy('./css/jqueryui-smoothness/images', './public/images', function(err){
  if (err) {
    console.error(err);
  }
});
var hem = require('hem-haml-coffee');
hem.exec(argv[0]);
