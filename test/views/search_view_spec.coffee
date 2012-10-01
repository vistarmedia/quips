test    = require '../setup'
expect  = require('chai').expect

SearchView = require 'views/search_view'


describe 'Search View', ->

  beforeEach ->
    test.create()
    @view = new SearchView().render()

  afterEach ->
    @view.remove()
    test.destroy()

  it 'should emit lower-cased change event', (done) ->
    checkSearch = (query) ->
      expect(query).to.equal 'cool dude'
      done()

    @view.on('change', checkSearch, this)
    @view.$el.find('input').val('Cool DUDE').keyup()
