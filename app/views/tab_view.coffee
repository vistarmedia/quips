$    = require 'jqueryify2'

View = require 'views/view'


class TabView extends View
  template: ->
    template = require 'templates/tab'
    tabsArray = ({
      name: name
      key: @_nameToKey(name)} for name in @tabsArray)
    template
      urlPrefix: if @urlPrefix? then @urlPrefix else ''
      tabsArray: tabsArray

  render: ->
    super
    @$el.find(".#{@_nameToKey(@selected)}").addClass('selected')
    this

  constructor: (@selected) ->
    super

  _nameToKey: (name) ->
    name.replace(/\W/g, '').toLowerCase()


module.exports = TabView
