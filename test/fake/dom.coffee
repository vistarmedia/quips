jsdom = require('jsdom').jsdom
global.document or= jsdom()
global.window   or= global.document.createWindow()

global.jQuery = require 'jqueryify'
global.jQuery.contains = -> true

Backbone      = require 'backbone'
Backbone.$    = global.jQuery


afterEach ->
  global.document.write ''


module.exports =
  window: global.window
  jQuery: global.jQuery
