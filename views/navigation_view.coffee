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
    link = @$el.find("a.#{name}")
    menu = @$el.find("ul.secondary.#{name}")

    link.parent('li').addClass('active')
      .siblings().removeClass('active')

    if menu.length > 0
      menu.addClass('active')
        .siblings().removeClass('active')
    else
      @$el.find("ul.secondary.active").removeClass("active")

    @trigger('selected', name)

  updateSecondary: (location) ->
    # If the location is null, we're at the index and nothing should be active
    updated = $('<li>')
    linkInSecondary = false
    if location.length <= 0
      @$el.find('ul.primary li').removeClass('active')
      @$el.find('ul.secondary li').removeClass('active')
    else
      for secondary in @$el.find('ul.secondary > li > a')
        href = $(secondary).attr('href')
        if location[0...href.length] is href
          updated = $(secondary).parent()
          linkInSecondary = true

      for primary in @$el.find('ul.primary > li > a')
        primaryClass = $(primary).attr('class')
        if linkInSecondary
          if updated.parents('ul').hasClass(primaryClass)
            @selectPrimary(primaryClass)
        else
          href = $(primary).attr('href')
          if location[0...href.length] is href
            @selectPrimary $(primary).attr('class')

      @$el.find('ul.secondary li').removeClass('active')
      updated.addClass('active')

  render: ->
    super

    firstPrimary = @$el.find('ul.primary > li > a')
    @selectPrimary firstPrimary.attr('class')

    this


module.exports = NavigationView
