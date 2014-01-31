require '../setup'
expect = require('chai').expect

Collection         = require 'models/collection'
FilteredCollection = require 'models/filtered_collection'
Model              = require 'models/model'
PageableCollection = require 'models/pageable_collection'


class MockModel extends  Model

class MockCollection extends Collection
  model: MockModel
  url: '/mock/'


describe 'Pageable Collection', ->

  beforeEach ->
    @collection = new MockCollection()

  it 'should paginate a full collection', ->
    @collection.add(@collection.create id: i for i in [1..11])
    pageableCollection = new PageableCollection(@collection, pageSize: 5)

    expect(pageableCollection.length).to.equal 5
    expect(pageableCollection.fullCollection.length).to.equal 11
    expect(pageableCollection.fullCollection).to.equal @collection
    expect(pageableCollection.getNumberOfPages()).to.equal 3
    expect(pageableCollection.getCurrentPageNumber()).to.equal 1
    expect(pageableCollection.hasPrevious()).to.be.false
    expect(pageableCollection.hasNext()).to.be.true

    pageableCollection.getNextPage()
    expect(pageableCollection.length).to.equal 5
    expect(pageableCollection.getCurrentPageNumber()).to.equal 2
    expect(pageableCollection.hasPrevious()).to.be.true
    expect(pageableCollection.hasNext()).to.be.true

    pageableCollection.getNextPage()
    expect(pageableCollection.length).to.equal 1
    expect(pageableCollection.getCurrentPageNumber()).to.equal 3
    expect(pageableCollection.hasPrevious()).to.be.true
    expect(pageableCollection.hasNext()).to.be.false

  describe 'event handlers', ->

    beforeEach ->
      @collection.comparator = 'name'
      @collection.add([
        @collection.create(id: 1, name: 'A'),
        @collection.create(id: 2, name: 'C'),
        @collection.create(id: 3, name: 'D'),
        @collection.create(id: 4, name: 'E'),
        @collection.create(id: 5, name: 'F')
      ])
      @pageableCollection = new PageableCollection(@collection, pageSize: 3)
      expect(@pageableCollection.length).to.equal 3

    it 'should handle adds to the parent collection', ->
      @pageableCollection.setSorting('ASC', (model) -> model.get('name'))
      equalsACD = =>
        expect(@pageableCollection.length).to.equal 3
        expect(@pageableCollection.models[0].get('name')).to.equal 'A'
        expect(@pageableCollection.models[1].get('name')).to.equal 'C'
        expect(@pageableCollection.models[2].get('name')).to.equal 'D'

      equalsACD()
      @collection.add(@collection.create name: 'G')
      equalsACD() # G should be on another page so it will have no affect

      expect(@pageableCollection.getNumberOfPages()).to.equal 2
      @collection.add(@collection.create name: 'B')
      # we now have 7 items in the collection, the page will increment
      expect(@pageableCollection.getNumberOfPages()).to.equal 3

      expect(@pageableCollection.length).to.equal 3
      expect(@pageableCollection.models[0].get('name')).to.equal 'A'
      expect(@pageableCollection.models[1].get('name')).to.equal 'B'
      expect(@pageableCollection.models[2].get('name')).to.equal 'C'

      @pageableCollection.getPage(2)
      expect(@pageableCollection.length).to.equal 3
      expect(@pageableCollection.models[0].get('name')).to.equal 'D'
      expect(@pageableCollection.models[1].get('name')).to.equal 'E'
      expect(@pageableCollection.models[2].get('name')).to.equal 'F'
      @collection.add(@collection.create name: 'BB')
      expect(@pageableCollection.length).to.equal 3
      expect(@pageableCollection.models[0].get('name')).to.equal 'C'
      expect(@pageableCollection.models[1].get('name')).to.equal 'D'
      expect(@pageableCollection.models[2].get('name')).to.equal 'E'

      @pageableCollection.getPage(3)
      expect(@pageableCollection.getNumberOfPages()).to.equal 3
      expect(@pageableCollection.length).to.equal 2
      expect(@pageableCollection.models[0].get('name')).to.equal 'F'
      expect(@pageableCollection.models[1].get('name')).to.equal 'G'
      @collection.add(@collection.create name: 'CC')
      expect(@pageableCollection.getNumberOfPages()).to.equal 3
      expect(@pageableCollection.length).to.equal 3
      expect(@pageableCollection.models[0].get('name')).to.equal 'E'
      expect(@pageableCollection.models[1].get('name')).to.equal 'F'
      expect(@pageableCollection.models[2].get('name')).to.equal 'G'

    it 'should handle removes to the parent collection', ->
      modelG = @collection.create name: 'G'
      modelH = @collection.create name: 'H'
      @collection.add([modelG, modelH])
      @pageableCollection.getPage(2)
      expect(@pageableCollection.getNumberOfPages()).to.equal 3
      expect(@pageableCollection.length).to.equal 3

      # removing from the current page
      expect(@pageableCollection.models[2].get('name')).to.equal 'G'
      @collection.remove(modelG)
      expect(@pageableCollection.models[2].get('name')).to.equal 'H'
      expect(@pageableCollection.length).to.equal 3
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 2
      expect(@pageableCollection.getNumberOfPages()).to.equal 2

      # removing from before the current page
      @collection.shift()
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 2
      expect(@pageableCollection.getNumberOfPages()).to.equal 2
      expect(@pageableCollection.length).to.equal 2
      @collection.shift()
      @collection.shift()
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 1
      expect(@pageableCollection.getNumberOfPages()).to.equal 1
      expect(@pageableCollection.length).to.equal 3

      modelI = @collection.create name: 'I'
      modelJ = @collection.create name: 'J'
      @collection.add([modelI, modelJ])
      # removing from a full page will grab the model from the next page
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 1
      expect(@pageableCollection.getNumberOfPages()).to.equal 2
      expect(@pageableCollection.models[2].get('name')).to.not.equal 'I'
      @collection.remove(@pageableCollection.models[0])
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 1
      expect(@pageableCollection.getNumberOfPages()).to.equal 2
      expect(@pageableCollection.models[2].get('name')).to.equal 'I'

    it 'should handle resets to the parent collection', ->
      @pageableCollection.getPage(2)
      expect(@pageableCollection.getNumberOfPages()).to.equal 2
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 2

      @collection.reset([
        @collection.create(name: 'X'),
        @collection.create(name: 'Y')
      ])
      expect(@pageableCollection.getNumberOfPages()).to.equal 1
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 1
      expect(@pageableCollection.length).to.equal 2
      expect(@pageableCollection.models[0].get('name')).to.equal 'X'
      expect(@pageableCollection.models[1].get('name')).to.equal 'Y'

      @collection.reset([])
      expect(@pageableCollection.getNumberOfPages()).to.equal 1
      expect(@pageableCollection.getCurrentPageNumber()).to.equal 1
      expect(@pageableCollection.length).to.equal 0

    it 'should handler sort events to the parent collection', ->
      @collection.comparator = undefined
      expect(@pageableCollection.models[0].get('name')).to.equal 'A'
      expect(@pageableCollection.models[1].get('name')).to.equal 'C'
      expect(@pageableCollection.models[2].get('name')).to.equal 'D'
      @collection.add(@collection.create name: 'B')
      expect(@pageableCollection.models[1].get('name')).to.equal 'C'
      @collection.comparator = 'name'
      @collection.sort()
      expect(@pageableCollection.models[1].get('name')).to.equal 'B'

    it 'should handle removes from a filtered collection', ->
      filteredCollection = new FilteredCollection(@collection)
      pageableCollection = new PageableCollection(filteredCollection,
        pageSize: 3)

      expect(pageableCollection.length).to.equal 3
      expect(pageableCollection.models[0].get('name')).to.equal 'A'
      expect(pageableCollection.models[1].get('name')).to.equal 'C'
      expect(pageableCollection.models[2].get('name')).to.equal 'D'

      filteredCollection.addFilter 'name', (m) ->
        m.get('name') in ['A', 'E', 'F']

      expect(pageableCollection.length).to.equal 3
      expect(pageableCollection.models[0].get('name')).to.equal 'A'
      expect(pageableCollection.models[1].get('name')).to.equal 'E'
      expect(pageableCollection.models[2].get('name')).to.equal 'F'

  describe 'sorting', ->

    it 'should be able to sort across pages`', ->
      @collection.add([
        @collection.create(name: 'D'),
        @collection.create(name: 'F'),
        @collection.create(name: 'A'),
        @collection.create(name: 'E'),
        @collection.create(name: 'c')
      ])
      @pageableCollection = new PageableCollection(@collection, pageSize: 3)
      expect(@pageableCollection.length).to.equal 3
      expect(@pageableCollection.models[0].get('name')).to.equal 'D'
      expect(@pageableCollection.models[2].get('name')).to.equal 'A'

      @pageableCollection.setSorting('ASC', (model) ->
        model.get('name').toLowerCase())
      expect(@pageableCollection.models[0].get('name')).to.equal 'A'
      expect(@pageableCollection.models[1].get('name')).to.equal 'c'
      expect(@pageableCollection.models[2].get('name')).to.equal 'D'
      @pageableCollection.getNextPage()
      expect(@pageableCollection.models[0].get('name')).to.equal 'E'
      expect(@pageableCollection.models[1].get('name')).to.equal 'F'

      @pageableCollection.setSorting('DESC',
        (model) -> model.get('name').toLowerCase())
      @pageableCollection.getFirstPage()
      expect(@pageableCollection.models[0].get('name')).to.equal 'F'
      expect(@pageableCollection.models[1].get('name')).to.equal 'E'
      expect(@pageableCollection.models[2].get('name')).to.equal 'D'
      @pageableCollection.getNextPage()
      expect(@pageableCollection.models[0].get('name')).to.equal 'c'
      expect(@pageableCollection.models[1].get('name')).to.equal 'A'

  describe 'trigger events', ->

    it 'should trigger a current_page_changed event after the reset', (done) ->
      @collection.add([
        @collection.create(name: 'A'),
        @collection.create(name: 'B'),
        @collection.create(name: 'C')
      ])
      pageableCollection = new PageableCollection(@collection, pageSize: 2)

      expect(pageableCollection.length).to.equal 2
      expect(pageableCollection.models[0].get('name')).to.equal 'A'
      expect(pageableCollection.models[1].get('name')).to.equal 'B'

      pageableCollection.on('current_page_changed', (->
        expect(pageableCollection.length).to.equal 1
        expect(pageableCollection.models[0].get('name')).to.equal 'C'
        done()), this)

      pageableCollection.getPage(2)
