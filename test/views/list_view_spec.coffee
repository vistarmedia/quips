test    = require '../setup'
expect  = require('chai').expect
$       = require 'jqueryify2'

lists = require 'views/list_view'

Model       = require 'models/model'
Collection  = require 'models/collection'


class MockModel extends Model
  url:  '/fake'
  json: -> @toJSON()

class MockCollection extends Collection
  model: MockModel


describe 'ListView', ->

  beforeEach ->
    test.create()

    @collection = new MockCollection

  afterEach ->
    @collection.reset()
    test.destroy()

  it 'should not leak event references', ->
    model = new MockModel(id: 'model-1')
    @collection.add model

    listView = new lists.ListView(@collection)
    listeners = -> (v for k, v of model._callbacks)

    # First is caused by adding it to the backbone collection. Next two are the
    # change and delete listeners in the RowView.
    expect(do listeners).to.have.length 3

    listView.remove()

    # All that should be left is the collection binding
    expect(do listeners).to.have.length 1

  it 'should remove a row on deletion', ->
    model = new MockModel(id: 'model-1')
    @collection.add model

    listView = new lists.ListView(@collection)

    expect(listView.$el.children()).to.have.length 1

    model.destroy()

    expect(listView.$el.children()).to.have.length 0

  it 'should add row to map when created', ->
    model = new MockModel(id: 'model-1')

    listView = new lists.ListView(@collection)

    expect(listView.rows).to.be.empty
    listView._addItem(model)
    expect(listView.rows).to.not.be.empty
    expect(listView.rows['model-1']).to.be.defined

  it 'should remove row from map when deleted', ->
    model = new MockModel(id: 'model-1')
    @collection.add(model)

    listView = new lists.ListView(@collection)

    listView._addItem(model)
    expect(listView.rows).to.not.be.empty
    model.destroy()
    expect(listView.rows).to.be.empty

  it 'should filter models by some function', ->
    model1 = new MockModel(id: 'model-1', name: 'Model 1')
    model2 = new MockModel(id: 'model-2', name: 'Model 2')
    @collection.add(m) for m in [model1, model2]
    listView = new lists.ListView(@collection).render()

    expect(listView.$el.find('.hidden')).to.have.length 0

    listView.filterBy (net) -> net.get('name') is 'Model 1'

    expect(listView.$el.find('.hidden')).to.have.length 1

    expect(listView.$el.find('#model-1.hidden')).to.have.length 0
    expect(listView.$el.find('#model-2.hidden')).to.have.length 1

  it 'should order models by some function', ->
    model1 = new MockModel(id: 'model-1', name: 'BBB Model')
    model2 = new MockModel(id: 'model-2', name: 'AAA Model')
    @collection.add(m) for m in [model1, model2]
    listView = new lists.ListView(@collection).render()

    firstId = -> listView.$el.children().first().attr('id')

    listView.sortBy (net) -> net.get('name')
    expect(firstId()).to.equal 'model-2'

    listView.sortBy (net) -> net.id
    expect(firstId()).to.equal 'model-1'

  it 'should use the provided row class', ->
    class MockRowView extends lists.RowView
      render: -> this

    collection = new MockCollection
    model = new MockModel(id: 'model-1')

    listView = new lists.ListView(collection, MockRowView)
    listView._addItem(model)
    expect(listView.rows['model-1']).to.be.an.instanceof MockRowView

  it 'should render a layout template', ->
    class MockListView extends lists.ListView
      layout: ->
        $('<ul class="list"></ul>')

      template: (model) ->
        $("<li>#{model.name}</li>")

      listEl: -> @$el.find('.list')

    @collection.add
      id: '1'
      name: 'some model name'

    mlv = new MockListView(@collection).render()

    expect(mlv.html()).to.include 'some model name'
    expect(mlv.$el.find('.list li')).to.have.length 1

  it 'should setup all tables', ->
    class TableListView extends lists.ListView
      template: require './test_list_template'
      layout:   require './test_list_layout'

      listEl: -> @$el.find('.list')

    collection = new MockCollection
    collection.add id: 'model-1'
    collection.add id: 'model-2'
    collection.add id: 'model-3'
    collection.add id: 'model-4'

    view = new TableListView(collection).render()

    expect(view.$el.find('.row')).to.have.length 4
    expect(view.$el.find('.row.striped')).to.have.length 2
    expect($(view.$el.find('.row')[1])).to.have.class 'striped'
    expect($(view.$el.find('.row')[3])).to.have.class 'striped'
