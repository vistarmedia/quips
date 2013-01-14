View    = require './view'
Sticky  = require '../lib/sticky'
$       = require 'jqueryify2'


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

    # Only stick if the user will have to scroll -
    # that is, only if a sibling view is larger than the current window height
    contentHeight = Math.max($(x).height() for x in @$el.parent().siblings())
    if @opts?.sticky and contentHeight > $(window).height()
      Sticky.stickify @$el,
        padding: @opts?.stickyPadding or 0

    this


module.exports = DetailView
