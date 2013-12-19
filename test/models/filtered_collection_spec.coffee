require '../setup'
expect = require('chai').expect
_      = require 'underscore'

Collection         = require 'models/collection'
FilteredCollection = require 'models/filtered_collection'
Model              = require 'models/model'


class MockModel extends Model

class MockCollection extends Collection
  model: MockModel
  url: '/mock/'


describe 'Filtered Collection', ->

  beforeEach ->
    @m1 = new MockModel(id: 1, name: 'm1')
    @m2 = new MockModel(id: 2, name: 'm2')
    @m3 = new MockModel(id: 3, name: 'm3')
    @collection = new MockCollection([@m1, @m2, @m3])

  it 'should have all existing models on construction', ->
    expect(@collection.length).to.equal 3
    filtered = new FilteredCollection(@collection)
    expect(filtered.length).to.equal 3

  it 'should look a model up by its id', ->
    filtered = new FilteredCollection @collection

    expect(@collection.get(@m1.id)).to.equal @m1
    expect(filtered.get(@m1.id)).to.equal @m1

  it 'should add a model when added to the parent', ->
    filtered = new FilteredCollection @collection
    m4 = new MockModel(name: 'm4')

    expect(filtered.length).to.equal 3
    @collection.add m4
    expect(filtered.length).to.equal 4

  it 'should delete a model when deleted from the parent', ->
    @server.when 'DELETE', "/mock/#{@m1.id}", ->
      status: 204

    filtered = new FilteredCollection @collection
    expect(filtered.length).to.equal 3
    @m1.destroy()
    expect(filtered.length).to.equal 2
    expect(@collection.length).to.equal 2
    expect(filtered.length).to.equal 2

  it 'should apply filters to its internal collection', ->
    filtered = new FilteredCollection @collection
    expect(filtered.length).to.equal 3
    filtered.addFilter 'name', (m) ->
      m.get('name') is 'm1'

    expect(filtered.length).to.equal 1
    expect(@collection.length).to.equal 3
    expect(filtered.models[0]).to.equal @m1

  it 'should re-add models when their filter is deleted', ->
    filtered = new FilteredCollection @collection
    expect(filtered.length).to.equal 3
    filtered.addFilter 'name', (m) ->
      m.get('name') is 'm1'

    expect(filtered.length).to.equal 1
    expect(@collection.length).to.equal 3
    expect(filtered.models[0]).to.equal @m1

    filtered.removeFilter('name')
    expect(filtered.length).to.equal 3
    expect(@collection.length).to.equal 3
    expect(filtered.get(@m1.id)).to.equal @m1
    expect(filtered.get(@m2.id)).to.equal @m2
    expect(filtered.get(@m3.id)).to.equal @m3

  it 'should add models when no filter excludes them', ->
    filtered = new FilteredCollection @collection
    expect(filtered.length).to.equal 3
    filtered.addFilter 'name', (m) ->
      m.get('name') is 'm1'

    expect(filtered.length).to.equal 1
    expect(filtered.models[0]).to.equal @m1

    filtered.addFilter 'name', (m) ->
      m.get('name') is 'm2'

    expect(filtered.length).to.equal 1
    expect(filtered.models[0]).to.equal @m2

  it 'should trigger a filtered event when the model changes', (done) ->
    filtered = new FilteredCollection @collection

    @timesCalled = 0
    @m1.on('remove', (-> @timesCalled++), this)

    filtered.addFilter 'name', (m) ->
      m.get('name') is 'm2'

    _.defer =>
      expect(@timesCalled).to.equal 1
      done()
