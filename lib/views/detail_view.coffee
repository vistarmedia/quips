$       = require 'jqueryify'

View    = require './view'



class DetailView extends View

  events:
    'click .delete': 'delete'

  show: (@item) ->
    @item.on 'destroy', @empty, this
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
    this


module.exports = DetailView
