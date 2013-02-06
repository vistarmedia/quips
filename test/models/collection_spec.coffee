test    = require '../setup'
expect  = require('chai').expect
sinon   = require 'sinon'

Collection  = require 'models/collection'
Model       = require 'models/model'


class MockModel1 extends Model
class MockModel2 extends Model

class MockColletion1 extends Collection
  model: MockModel1
  url: '/mock1/'

class MockColletion2 extends Collection
  model: MockModel2
  url: '/mock2/'


describe 'Collection', ->

  beforeEach ->
    @state = test.create()

  afterEach ->
    @state.destroy()

  describe 'syncTo method', ->

    beforeEach ->
      @clock = sinon.useFakeTimers()
      @mock1FetchCount = 0
      @mock2FetchCount = 0

      test.when 'GET', '/mock1/', =>
        @mock1FetchCount++
        body: JSON.stringify([{id: 2},{id: 3}])

      test.when 'GET', '/mock2/', =>
        @mock2FetchCount++
        body: JSON.stringify([{id: 1}])

      @mock1 = new MockColletion1()
      @mock2 = new MockColletion2()

    afterEach ->
      @clock.restore()

    it 'should fetch the other collection when a model is added', ->
      @mock1.syncTo(@mock2)
      @mock2.add(new MockModel2())
      @mock1.add(new MockModel1())
      @mock1.add(new MockModel1())

      @clock.tick(300)
      expect(@mock1FetchCount).to.equal 1
      expect(@mock2FetchCount).to.equal 2

    it 'should fetch the other collection when a model is removed', ->
      @mock2.add(new MockModel2(id: 1))
      @mock1.add(new MockModel1(id: 2))
      @mock1.add(new MockModel1(id: 3))

      @mock1.syncTo(@mock2)
      @mock2.remove([1])
      @mock1.remove([2, 3])
      @clock.tick(300)

      expect(@mock1FetchCount).to.equal 1
      expect(@mock2FetchCount).to.equal 2

    it 'should fetch the other collection when a model is saved', ->
      test.when 'PUT', '/mock1/2', ->
        status: 200

      model = new MockModel1(id: 2)

      @mock2.add(new MockModel2(id: 1))
      @mock1.add(model)
      @mock1.add(new MockModel1(id: 3))

      @mock1.syncTo(@mock2)
      model.save()
      @clock.tick(300)

      expect(@mock1FetchCount).to.equal 0
      expect(@mock2FetchCount).to.equal 1

    it 'should not fetch the other collection when a model is changed', ->
      model = new MockModel1(id: 2)

      @mock2.add(new MockModel2(id: 1))
      @mock1.add(model)
      @mock1.add(new MockModel1(id: 3))

      @mock1.syncTo(@mock2)
      model.set(name: 'test')
      @clock.tick(300)

      expect(@mock1FetchCount).to.equal 0
      expect(@mock2FetchCount).to.equal 0

    it 'should always fetch the other collection second', ->
      @modelSaved = false

      test.when 'PUT', '/mock1/2', =>
        @modelSaved = true
        status: 200

      test.when 'GET', '/mock2/', =>
        if not @modelSaved
          throw new Exception('Fetched before model saved')

      model = new MockModel1(id: 2)
      @mock1.add(model)
      @mock1.syncTo(@mock2)

      for i in [1..100]
        @modelSaved = false
        model.save()
        @clock.tick(300)
