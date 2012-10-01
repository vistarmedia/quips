$    = require 'jqueryify2'
View = require 'views/view'


class NavigationView extends View
  template: require 'templates/navigation'

  events:
    'click ul.primary a':   'clickPrimary'

  constructor: (@model) ->
    super

  clickPrimary: (e) ->
    e.preventDefault()
    @selectPrimary $(e.currentTarget).attr('class')

  selectPrimary: (name) ->
    link = @$("a.#{name}")
    menu = @$("ul.secondary.#{name}")

    link.parent('li').addClass('active')
      .siblings().removeClass('active')

    menu.addClass('active')
      .siblings().removeClass('active')

    @trigger('selected', name)

  updateSecondary: (location) ->
    firstUrlPart = location.match(/(#\/[^\/]+\/).*/)[1]
    updated = @$("[href=\"#{firstUrlPart}\"]")
    for primary in @$('ul.primary > li > a')
      primaryClass = $(primary).attr('class')
      if updated.parents('ul').hasClass(primaryClass)
        @selectPrimary(primaryClass)

    @$('ul.secondary li a').removeClass('active')
    updated.addClass('active')

  render: ->
    super

    firstPrimary = @$el.find('ul.primary > li > a')
    @selectPrimary firstPrimary.attr('class')

    this


module.exports = NavigationView
