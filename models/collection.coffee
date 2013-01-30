Backbone = require 'backbone'

events = require '../lib/events'


class Collection extends Backbone.Collection
  create: ->
    model = new @model(arguments...)
    model.collection = this
    model

  lazy: false

  syncTo: (otherCol) ->
    @on('sync add remove', ((model, resp, opts) ->
      unless opts.from_handler
        otherCol.fetch(update: true, from_handler: true)), this)

    otherCol.on('sync add remove', ((model, resp, opts) =>
      unless opts.from_handler
        @fetch(update: true, from_handler: true)), this)


module.exports = events.track Collection
