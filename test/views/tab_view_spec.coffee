test    = require '../setup'
expect  = require('chai').expect
$       = require 'jqueryify2'

TabView = require('views/tab_view')

class TestTabView extends TabView
  tabsArray: ['test 1', 'test 2', 'test 3']
  urlPrefix: '/foo'

describe 'TabView', ->

  beforeEach ->
    test.create()
    @tabView = new TestTabView('test 1').render()

  afterEach ->
    test.destroy()

  it 'should select the right tab', ->
    expect(@tabView.$el).to.have.element('.tab.test1.selected')

  it 'should have the right ammount of tabs', ->
    expect(@tabView.$el.find('.tab')).to.have.length 3

  it 'should append a url prefix to the link', ->
    expect(@tabView.$el).to.have.element('a[href="#/foo/test1/"]')

