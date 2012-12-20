hem = require 'hem-haml-coffee'

process.env.TZ = 'EST'

jsdom = require('jsdom').jsdom
global.document or= jsdom()
global.window   or= global.document.createWindow()

global.window.confirm = -> true
global.jQuery         = require 'jqueryify2'

Backbone        = require 'backbone'
datepicker      = require 'lib/jquery-ui-1.8.22.datepicker-only.min'
MockHttpServer  = require('./lib/mock_server').MockHttpServer

require.extensions['.haml'] = (module, filename) ->
  module._compile(hem.compilers.haml(filename))


class TestState

  destroy: ->
    module.exports.destroy()


module.exports =
  create: ->
    @_setup()
    @patterns = []
    global.window.confirm = -> true
    new TestState

  destroy: ->
    @server.stop()
    document.write ''

  when: (method, url, respond) ->
    @patterns.push [method, url, respond]

  fail: ->
    throw new Error(arguments...)

  _setup: ->
    Backbone.setDomLibrary jQuery

    chai = require 'chai'
    ext  = require './lib/chai_extensions'
    chai.use(ext)

    @server = new MockHttpServer (req) => @_handleRequest req
    @server.start()

  _handleRequest: (request) ->
    handed = false

    for [method, url, respond] in @patterns
      if method is request.method and url is request.url
        resp = respond(request) or {}
        resp.status   or= 200
        resp.body     or= ''

        request.receive resp.status, resp.body
        handed = true

    unless handed
      request.receive 404, 'Not Found'
