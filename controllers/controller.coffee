Backbone = require 'backbone'
$        = require 'jqueryify'

events = require '../lib/events'


class Controller extends Backbone.Router
  views: {}
  events: {}

  constructor: (opts) ->
    super

    @history = if (opts? and opts.history?) then opts.history else Backbone.history
    @_localEl = @_createLocalEl()
    @_pageEl  = $(opts?.el or '<div>')

    @_setupViews()
    @_setupEventHandling()

  activate: ->
    @_pageEl.children().detach()
    @_pageEl.append(@_localEl)
    @_cleanupChildView()
    this

  destroy: ->
    @_cleanupChildView()

    for _, viewName of @views
      @[viewName].remove()

    for pattern, methodName of @events
      [viewName, match] = pattern.split '.'
      view   = @[viewName]
      view.off match

  trackNew: ->
    @_cleanupChildView()
    args = (v for k, v of arguments)
    controllerType  = args[0]

    initArgs  = args[1..]
    initArgs.push {el: @_pageEl}

    @_child = new controllerType(initArgs...)
    @_child

  _createLocalEl: ->
    $('<div>').addClass(@constructor.name)
      .append(@layout())

  _render: ->
    if @layout then @$el.empty().append(@layout())
    @_setupViews()

  _setupViews: ->
    selectors = Object.keys(@views)
    selectors.sort()

    for selector in selectors
      @_localEl.find(selector).append(@[@views[selector]].el)

  _setupEventHandling: ->
    for pattern, methodName of @events
      [viewName, match] = pattern.split '.'
      method = @[methodName]
      view   = @[viewName]
      view.on(match, method, this)

  _cleanupChildView: ->
    @_child?.destroy()
    @_child = undefined

module.exports = events.track Controller
