#quips
a leak-plugging layer on top of backbone.js

```coffeescript
$          = require 'jqueryify2'
datepicker = require 'lib/jquery-ui-1.8.22.datepicker-only.min'
Backbone   = require 'backbone'

loadModel       = require 'models/loader'

NavigationController   = require 'controllers/navigation_controller'


class App

  # Create the applicatoin with the given API root. All AJAX requests will be
  # made relative to this root. If omitted, the application will run as if it
  # was being served from / on the same host as the API.
  constructor: (@apiRoot) ->
    module.exports.apiRoot = @apiRoot

    root = $('body')
    @loginController = new LoginController(el: root)

    (do @login)
      .pipe(@loadModel)
      .pipe(@showUI)

  login: =>
    User.authenticateAgainst(@apiRoot)
    @loginController.login()

  loadModel: =>
    $('body').text('loading...')
    loadModel(@apiRoot)

  showUI: (model) =>
    layout = $('body').empty().append(require 'templates/layout')

    main        = layout.find('.body')
    navigation  = layout.find('.navigation')

    Backbone.history.start()


module.exports.app = App

```