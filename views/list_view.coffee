_ = require 'underscore'

View = require './view'


class RowView extends View
  events:
    'click': '_selected'

  constructor: (@model, @template) ->
    super(id: @model.id)

    @model.on 'change', @render, this
    @model.on 'destroy', @remove, this

  highlight: ->
    @$el.addClass('selected')
      .siblings().removeClass('selected')

  show: ->
    @$el.removeClass('hidden')

  hide: ->
    @$el.addClass('hidden')

  _selected: ->
    @highlight()
    @trigger 'select', @model


class ListView extends View
  collection: null

  layout: null

  listEl: ->
    @$el

  template: ->

  constructor: (@items, @rowClass) ->
    super

    @rows = {}
    @items.on 'add',    @_addItem,  this
    @items.on 'reset',  @_reset,    this
    @items.on 'change', @render,    this

    if @layout? then @append(@layout())
    @_reset()

  select: (item) ->
    @rows[item.id]?.highlight()

  filterBy: (filter) ->
    for id, rowView of @rows
      if filter(rowView.model) then rowView.show() else rowView.hide()

  sortBy: (sort) ->
    models = _.sortBy @items.models, (id) => sort(@items.get(id))

    cursor = null
    for model in models
      el = @rows[model.id].$el
      cursor?.after el
      cursor = el

  clearSelection: ->
    @$el.find('.selected').removeClass('selected')

  _reset: ->
    @listEl().empty()
    @_addItem(i) for i in @items.models

  _addItem: (item) ->
    rowClass = @rowClass or RowView
    row = new rowClass(item, @template).render()
    @rows[item.id] = row
    item.on('remove', (=> delete @rows[item.id]), this)
    @append(row, @listEl())
    row.on('select', ((model) -> @trigger 'select', model), this)

  render: ->
    @_setupTables()
    @populate()
    this


module.exports =
  ListView: ListView
  RowView: RowView
