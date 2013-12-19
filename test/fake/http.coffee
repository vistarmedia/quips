{HttpServer} = require('honk-test-net')


module.exports = (window) ->
  beforeEach ->
    @server = new HttpServer(window)
    @server.start()

  afterEach ->
    @server.stop()


  @server
