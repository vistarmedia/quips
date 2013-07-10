Backbone = require 'backbone'
_        = require 'underscore'

events = require '../lib/events'


makeComparator = (order, sortFunc) ->
  (left, right) ->
    l = sortFunc(left)
    r = sortFunc(right)
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

  setSorting: (order, sortFunc) ->
    unless _.isFunction(sortFunc)
      throw TypeError('Second argument to setSorting must be a function')
    unless order is 'DESC' or order is 'ASC'
      throw TypeError(
        "First argument to setSorting must be either 'DESC' or 'ASC'")
    @comparator = makeComparator(order, sortFunc)
    @sort()


module.exports = events.track Collection
