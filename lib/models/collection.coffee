Backbone = require 'backbone'

events = require '../lib/events'


makeComparator = (sortKey, order, sortValue) ->
  return unless sortKey? and order?
  unless sortValue? then sortValue = (model, attr) -> model.get(attr)

  (left, right) ->
    l = sortValue(left, sortKey)
    r = sortValue(right, sortKey)
    if (order is 'DESC')
      temp = l
      l = r
      r = temp

    if (l is r) then 0
    else if (l < r) then -1
    else 1


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

  setSorting: (sortKey, order, sortValue) ->
    return unless sortKey? and order?
    @comparator = makeComparator(sortKey, order, sortValue)
    @sort()


module.exports = events.track Collection
