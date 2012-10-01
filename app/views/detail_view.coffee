View = require 'views/view'


class DetailView extends View

  events:
    'click .delete': 'delete'

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
    this


module.exports = DetailView
