test    = require '../setup'
expect  = require('chai').expect

NavigationView = require 'views/navigation_view'


describe 'NavigationView', ->
  beforeEach ->
    test.create()
    @view = new NavigationView()

  afterEach ->
    test.destroy()
    @view.remove()

  # This will error out as of d5f00da
  it 'should handle blank routes as catch-all', ->
    @view.updateSecondary('')
