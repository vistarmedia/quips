test    = require '../setup'
expect  = require('chai').expect

Model      = require 'models/model'
DetailView = require 'views/detail_view'


class TestModel extends Model

class TestDetailView extends DetailView
  template: require '../templates/detail_view'


describe 'Test Detail View', ->

  beforeEach ->
    test.create()

    @view = new TestDetailView
    @item = new TestModel
      id:   'net-1'
      name: 'Test 1'

  afterEach ->
    @view.remove()
    test.destroy()

  it 'should show nothing by default', ->
    expect(@view.render().html()).to.be.empty

    @view.show(@item)
    expect(@view.render().html()).to.not.be.empty

  it 'should show details about a item when shown', ->
    @view.show(@item)
    expect(@view.render().html()).to.include 'Test 1'

  it 'should have a delete button', ->
    @view.render()
    expect(@view.$el.find('.delete')).to.have.length 0
    @view.show(@item)
    expect(@view.$el.find('.delete')).to.have.length 1

  it 'should emit a delete event on click', (done) ->
    checkClick = (item) =>
      expect(item.id).to.equal @item.id
      done()

    @view.on('delete', checkClick, this)

    @view.render().show(@item)
    @view.$el.find('.delete').click()

  it 'emit delete events for all items', (done) ->
    item1 = new TestModel(id: 'net-1')
    item2 = new TestModel(id: 'net-2')

    numDeletes = 0
    checkDelete = (item) ->
      numDeletes++
      switch numDeletes
        when 1
          expect(item.id).to.equal 'net-1'
        when 2
          expect(item.id).to.equal 'net-2'
          done()

    @view.on('delete', checkDelete, this)

    @view.show(item1)
    @view.$el.find('.delete').click()

    @view.empty()
    @view.show(item2)
    @view.$el.find('.delete').click()

