Backbone = require 'backbone'

events = require '../lib/events'


class Collection extends Backbone.Collection
  create: ->
    model = new @model(arguments...)
    model.collection = this
    model

  lazy: false

  # the timeout is used to account for eventual consistency. This can be removed
  # if we are using an ACID database.
  syncTo: (otherCol, timeout=500) ->
    events = 'sync add remove'

    syncThis = (model, resp, opts) ->
      fetch = -> otherCol.fetch(update: true, from_handler: true)
      unless opts.from_handler then setTimeout(fetch, timeout)

    syncOther = (model, resp, opts) =>
      fetch = => @fetch(update: true, from_handler: true)
      unless opts.from_handler then setTimeout(fetch, timeout)

    @on(events, syncThis, this)
    otherCol.on(events, syncOther, this)


module.exports = events.track Collection
