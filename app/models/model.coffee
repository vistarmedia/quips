_        = require 'underscore'
Backbone = require 'backbone'

events = require 'lib/events'


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
  # For simplicity's sake, we'll just using json(), and let Backbone own
  # toJSON()
  json: ->_.extend(@toJSON(), @extraAttributes())

  extraAttributes: -> {}

module.exports = events.track Model
