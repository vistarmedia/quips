Backbone = require 'backbone'

events = require '../lib/events'


class Collection extends Backbone.Collection
  create: ->
    model = new @model(arguments...)
    model.collection = this
    model

  lazy: false

  syncTo: (otherCol) ->
    events = 'sync add remove'

    syncThis = (model, resp, opts) ->
      unless opts.from_handler
        otherCol.fetch(update: true, from_handler: true)

    syncOther = (model, resp, opts) =>
      unless opts.from_handler
        @fetch(update: true, from_handler: true)

    @on(events, syncThis, this)
    otherCol.on(events, syncOther, this)


module.exports = events.track Collection
