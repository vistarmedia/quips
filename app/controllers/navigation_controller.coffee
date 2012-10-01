_               = require 'underscore'
Backbone        = require 'backbone'

Controller      = require 'controllers/controller'
NavigationView  = require 'views/navigation_view'


class NavigationController extends Controller
  layout:   _.template('<div></div>')

  views:
    'div': 'navigation'

  constructor: (@user, opts) ->
    @navigation = new NavigationView(@user).render()
    super(opts)

    @history = opts.history or Backbone.history
    @history.on('route', @navigated, this)

  destroy: ->
    @history.off 'all'
    super

  navigated: ->
    @navigation.updateSecondary(document.location.hash)

module.exports = NavigationController
