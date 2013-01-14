View  = require './view'
$     = require 'jqueryify2'


class NavigationView extends View
  events:
    'click ul.primary a':   'clickPrimary'

  constructor: (@model, @template) ->
    super(@model)

  clickPrimary: (e) ->
    e.preventDefault()
    @selectPrimary $(e.currentTarget).attr('class')
    @trigger('primaryClick', $(e.currentTarget).attr('href'))

  selectPrimary: (name) ->
    link = $("a.#{name}")
    menu = $("ul.secondary.#{name}")

    link.parent('li').addClass('active')
      .siblings().removeClass('active')

    menu.addClass('active')
      .siblings().removeClass('active')

    @trigger('selected', name)

  updateSecondary: (location) ->
    # If the location is null, we're at the index and nothing should be active
    updated = $('<li>')

    if location.length <= 0
      $('ul.primary li').removeClass('active')
      $('ul.secondary li').removeClass('active')
    else
      $('ul.secondary> li > a').each (i, item) ->
        $item = $(item)
        href = $item.attr('href')
        if location[0...href.length] is href
          updated = $item.parent()
      for primary in $('ul.primary > li > a')
        primaryClass = $(primary).attr('class')
        if updated.parents('ul').hasClass(primaryClass)
          @selectPrimary(primaryClass)

      $('ul.secondary li').removeClass('active')
      updated.addClass('active')

  render: ->
    super

    firstPrimary = @$el.find('ul.primary > li > a')
    @selectPrimary firstPrimary.attr('class')

    this


module.exports = NavigationView
