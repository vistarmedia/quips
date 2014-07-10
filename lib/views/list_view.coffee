$ = require 'jqueryify'
_ = require 'underscore'

View = require './view'


class RowView extends View
  events:
    'click': '_selected'

  constructor: (@model, @template, @opts) ->
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
    unless @opts?.unselectable
      @highlight()
      @trigger 'select', @model


class ListView extends View
  collection: null

  layout: null

  defaultSort: null

  comparators: {}

  listEl: ->
    @$el

  template: ->

  events:
    'click .sort': '_sortClickHandler'

  constructor: (@items, @rowClass, @opts) ->
    super

    @sortState = {}
    @rows = {}
    @items.on 'add',         @_addItem,     this
    @items.on 'remove',      @_removeItem,  this
    @items.on 'reset',       @_reset,       this
    @items.on 'sort',        @_sortHandler, this
    @items.on 'change sync', @render,       this

    if @layout? then @append(@layout())
    @_reset()

  select: (item) ->
    unless @opts?.unselectable
      @rows[item.id]?.highlight()
      @selectedItem = item

  filterBy: (filter) ->
    for id, rowView of @rows
      if filter(rowView.model) then rowView.show() else rowView.hide()

  clearSelection: ->
    @$el.find('.selected').removeClass('selected')
    @selectedItem = null

  sortBy: (key, direction) ->
    unless direction is 'ASC' or direction is 'DESC'
      direction = @_getSortDirection(key)
    @sortState = {}
    @sortState[key] = direction
    @items.setSorting(direction, @comparators[key])
    element = @$el.find(".sort[data-comparator=#{key}]")
    @_addSortClassForHeader(element, direction)

  _sortClickHandler: (e) ->
    element = $(e.currentTarget)
    comparator = element.data('comparator')

    if comparator? and @comparators[comparator]?
      direction = @_getSortDirection(comparator)
      @sortBy(comparator, direction)

  _getSortDirection: (key) ->
    if @sortState[key] is 'ASC' then 'DESC' else 'ASC'

  _addSortClassForHeader: (element, direction) ->
    classes = _.values(@_cssSortingClasses).join(' ')
    @$el.find('th').removeClass(classes)
    element.addClass(@_cssClassForDirection(direction))

  _cssSortingClasses:
    'ASC':   'sorted direction-asc'
    'DESC':  'sorted direction-desc'

  _cssClassForDirection: (direction) ->
    @_cssSortingClasses[direction] or ''

  _sortHandler: ->
    listEl = @listEl()
    for model in @items.models
      @append(@rows[model.id].el, listEl)

  _reset: ->
    @listEl().empty()
    for key, view of @rows
      view.remove()
      delete @rows[key]
    @selectedItem = null unless @items.get(@selectedItem?.id)
    @_addItem(i) for i in @items.models
    @select(@selectedItem) if @selectedItem?

  _addItem: (item) ->
    rowClass = @rowClass or RowView
    row = new rowClass(item, @template, @opts).render()
    @rows[item.id] = row
    @append(row, @listEl())
    row.on('select', ((model) =>
      if model isnt @selectedItem
        @selectedItem = model
        @trigger 'select', model), row)

  _removeItem: (item) ->
    @rows[item.id]?.remove()
    delete @rows[item.id]
    @selectedItem = null if @selectedItem is item

  render: ->
    if _.isEmpty(@sortState) and @defaultSort?
      @sortBy(@defaultSort[0], @defaultSort[1])
    @populate()
    this


module.exports =
  ListView:  ListView
  RowView:   RowView
