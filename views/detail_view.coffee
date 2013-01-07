View    = require './view'
Sticky  = require '../lib/sticky'


class DetailView extends View

  events:
    'click .delete': 'delete'

  constructor: (@opts) ->
    super

  show: (@item) ->
    @render()

  delete: (e) ->
    e.preventDefault()
    @trigger('delete', @item)

  empty: ->
    @$el.empty()
    this

  render: ->
    return this unless @item?
    @html @template(@item.json())
    @populate()

    if @opts?.sticky
      Sticky.stickify @$el,
        padding: @opts?.stickyPadding or 0

    this


module.exports = DetailView
