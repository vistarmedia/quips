hem = require 'hem-haml-coffee'

process.env.TZ = 'EST'

# setup:    window global, fake dom, jquery, jquery for Backbone
# teardown: write empty string to document
window = require('./fake/dom').window
# setup:    window.confirm function to return true
# teardown: restore original confirm function
require('./fake/confirm')(window)
# setup:    fake XMLHTTPRequest thru honk-test-net, sets @server
# teardown: remove after each
require('./fake/http')(window)


require.extensions['.haml'] = (module, filename) ->
  module._compile(hem.compilers.haml(filename))


chai = require 'chai'
ext  = require 'vistar-chai-extensions'
chai.use(ext)
