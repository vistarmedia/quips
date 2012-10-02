Backbone = require 'backbone'

events = require '../lib/events'


class Collection extends Backbone.Collection
  create: ->
    model = new @model(arguments...)
    model.collection = this
    model

module.exports = events.track Collection
