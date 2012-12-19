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

    if @opts.sticky
      Sticky.stickify(@$el)

    this


module.exports = DetailView
