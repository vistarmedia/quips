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
        # the timeout is used to account for eventual consistency. This can be
        # removed if we are using an ACID database.
        setTimeout((-> otherCol.fetch(update: true, from_handler: true)), 150)
      ), this)

    otherCol.on('sync add remove', ((model, resp, opts) =>
      unless opts.from_handler
        setTimeout((=> @fetch(update: true, from_handler: true)), 150)
    ), this)


module.exports = events.track Collection
