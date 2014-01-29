require '../setup'
expect  = require('chai').expect
$       = require 'jqueryify'
_       = require 'underscore'

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
    @collection = new MockCollection

  afterEach ->
    @collection.reset()

  it 'should not leak event references', ->
    model = new MockModel(id: 'model-1')
    @collection.add model

    listView = new lists.ListView(@collection)
    listeners = -> _.flatten((v for k, v of model._events))

    # First is caused by adding it to the backbone collection. Next two are the
    # change and delete listeners in the RowView.
    expect(do listeners).to.have.length 3

    listView.remove()

    # All that should be left is the collection binding
    expect(do listeners).to.have.length 1

  it 'should not leak event references on reset', ->
    model = new MockModel(id: 'model-1')
    @collection.add model
    listView = new lists.ListView(@collection)
    listeners = -> _.flatten((v for k, v of model._events))
    expect(do listeners).to.have.length 3
    @collection.reset([])
    expect(do listeners).to.have.length 0

  it 'should not leak event references on select', ->
    model = new MockModel(id: 'model-1')
    @collection.add model
    listView = new lists.ListView(@collection)
    row = listView.rows[model.id]
    listeners = -> _.flatten((v for k, v of row._events))
    expect(do listeners).to.have.length 1
    row.remove()
    expect(do listeners).to.have.length 0

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

  it 'should keep the selected item when reset', ->
    modelA = @collection.create id: 'a'
    modelB = @collection.create id: 'b'
    modelC = @collection.create id: 'c'
    @collection.add([modelA, modelB, modelC])

    view = new lists.ListView @collection, lists.RowView
    view.render()
    view.rows['b'].$el.click()
    expect($(view.listEl()).find('.selected').length).to.equal 1
    expect(view.rows['b'].$el).class 'selected'

    @collection.reset([modelA, modelB])

    expect($(view.listEl()).find('.selected').length).to.equal 1
    expect(view.rows['b'].$el).class 'selected'

    @collection.reset([modelA])
    expect($(view.listEl()).find('.selected').length).to.equal 0


  describe 'sorting', ->

    beforeEach ->
      class MockRowView extends lists.RowView
        tagName: 'tr'
        template: (model) -> "<td>#{model.name}</td>"
        constructor: (@model) ->
          super(@model, @template)

      class MockListView extends lists.ListView
        comparators:
          name: (model) -> model.get('name')?.toLowerCase()
          place: (model) -> model.get('name')?.toLowerCase()

        layout: -> """
          <table>
            <thead>
              <th class="sort" data-comparator="name" id="nameHeader"></th>
              <th class="sort" data-comparator="place" id="placeHeader"></th>
            </thead>
            <tbody></tbody>
          </table>
        """

        listEl: -> @$el.find('tbody')

      @collection.add
        id: '1'
        name: 'AA model'
        place: 'Out on Houston'

      @collection.add
        id: '2'
        name: 'CC model'
        place: 'Broadway'

      @collection.add
        id: '3'
        name: 'bb model'
        place: 'Browsin'

      @mlv = new MockListView(@collection, MockRowView).render()

    it 'should sort ASC/DESC based on the comparators', ->
      rows = @mlv.listEl().find('tr')
      expect(rows.length).to.equal 3
      expect($(rows[0]).find('td').html()).to.equal 'AA model'
      expect($(rows[1]).find('td').html()).to.equal 'CC model'
      expect($(rows[2]).find('td').html()).to.equal 'bb model'

      @mlv.$el.find('#nameHeader').click()
      rows = @mlv.listEl().find('tr')
      expect(rows.length).to.equal 3
      expect($(rows[0]).find('td').html()).to.equal 'AA model'
      expect($(rows[1]).find('td').html()).to.equal 'bb model'
      expect($(rows[2]).find('td').html()).to.equal 'CC model'

      @mlv.$el.find('#nameHeader').click()
      rows = @mlv.listEl().find('tr')
      expect(rows.length).to.equal 3
      expect($(rows[0]).find('td').html()).to.equal 'CC model'
      expect($(rows[1]).find('td').html()).to.equal 'bb model'
      expect($(rows[2]).find('td').html()).to.equal 'AA model'

    it 'should stay sorted when adding/removing', ->
      @mlv.sortBy('name', 'DESC')
      rows = @mlv.listEl().find('tr')
      expect(rows.length).to.equal 3
      expect($(rows[0]).find('td').html()).to.equal 'CC model'
      expect($(rows[1]).find('td').html()).to.equal 'bb model'
      expect($(rows[2]).find('td').html()).to.equal 'AA model'

      @collection.add
        id: '4'
        name: 'ab model'

      rows = @mlv.listEl().find('tr')
      expect(rows.length).to.equal 4
      expect($(rows[0]).find('td').html()).to.equal 'CC model'
      expect($(rows[1]).find('td').html()).to.equal 'bb model'
      expect($(rows[2]).find('td').html()).to.equal 'ab model'
      expect($(rows[3]).find('td').html()).to.equal 'AA model'

      @collection.remove '3'
      rows = @mlv.listEl().find('tr')
      expect(rows.length).to.equal 3
      expect($(rows[0]).find('td').html()).to.equal 'CC model'
      expect($(rows[1]).find('td').html()).to.equal 'ab model'
      expect($(rows[2]).find('td').html()).to.equal 'AA model'

    it 'should keep the correct row highlighted', ->
      @mlv.sortBy('name', 'DESC')
      @mlv.rows['2'].highlight()
      rows = @mlv.listEl().find('tr')
      expect($(rows[0]).find('td').html()).to.equal 'CC model'
      expect($(rows[0])).class 'selected'

      @mlv.sortBy('name', 'ASC')
      rows = @mlv.listEl().find('tr')
      expect($(rows[2]).find('td').html()).to.equal 'CC model'
      expect($(rows[2])).class 'selected'

    it 'should add a css class to header to indicate sorting', ->
      header = @mlv.$el.find('#nameHeader')
      header.click()

      expect(header).to.have.class 'sorted'
      expect(header).to.have.class 'direction-asc'

      header.click()
      expect(header).to.have.class 'direction-desc'

    it 'should remove header sort class when another header is clicked', ->
      nameHeader = @mlv.$el.find('#nameHeader')
      nameHeader.click()

      expect(nameHeader).to.have.class 'direction-asc'

      placeHeader = @mlv.$el.find('#placeHeader')

      placeHeader.click()

      expect(nameHeader).not.to.have.class 'sorted'
      expect(nameHeader).not.to.have.class 'direction-asc'

    it 'should use a default sorting', ->
      class MockDefaultSortRowView extends lists.RowView
        tagName: 'tr'
        template: (model) -> "<td>#{model.name}</td>"
        constructor: (@model) ->
          super(@model, @template)

      class MockDefaultSortListView extends lists.ListView
        comparators:
          name: (model) -> model.get('name')?.toLowerCase()

        layout: -> """
          <table>
            <thead>
              <th class="sort" data-comparator="name" id="nameHeader"></th>
            </thead>
            <tbody></tbody>
          </table>
        """

        listEl: -> @$el.find('tbody')

        defaultSort: ['name', 'ASC']

      collection = new Collection([
        new Model(
          id: '1'
          name: 'AA model'
        ),
        new Model(
          id: '2'
          name: 'CC model'
        ),
        new Model(
          id: '3'
          name: 'bb model'
        )])

      mlv = new MockDefaultSortListView(collection, MockDefaultSortRowView)

      rows = mlv.listEl().find('tr')
      expect($(rows[0]).find('td').html()).to.equal 'AA model'
      expect($(rows[1]).find('td').html()).to.equal 'CC model'
      expect($(rows[2]).find('td').html()).to.equal 'bb model'
      mlv.render()
      newRows = mlv.listEl().find('tr')
      expect($(newRows[0]).find('td').html()).to.equal 'AA model'
      expect($(newRows[1]).find('td').html()).to.equal 'bb model'
      expect($(newRows[2]).find('td').html()).to.equal 'CC model'
