_        = require 'underscore'
Backbone = require 'backbone'

events = require '../lib/events'


class Model extends Backbone.Model

  save: ->
    isNew = @isNew()
    result = super
    if isNew then result.done => @collection?.add(this)
    result

  destroy: ->
    @unregister()
    super

  # By default, Backbone will use toJSON to determine what to send to the server
  # on creation and update. This is at odds with using toJSON in the views,
  # which is generally both basic and computed attributes.
  #
  # Each object will have a "extend" method -- often useful when overriding
  # templates. For example
  #
  #     class MyWidget extends Quips.View
  #       _template: require 'cool/pics'
  #
  #       constructor: (@width, @model) ->
  #         super()
  #
  #       template: (json) ->
  #         @_template(json.extend(width: @width))
  #
  json: ->
    params = _.extend(@toJSON(), @extraAttributes())
    params.extend = (extra) -> _.extend(params, extra)
    params

  extraAttributes: -> {}

module.exports = events.track Model
