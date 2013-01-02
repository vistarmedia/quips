test    = require '../setup'
expect  = require('chai').expect
$       = require 'jqueryify2'

Collection  = require 'models/collection'
Model       = require 'models/model'

load = require('models/loader').load


class MockModel extends Model

describe 'Model Loader', ->

  beforeEach ->
    @state = test.create()

  afterEach ->
    @state.destroy()

  it 'should handle collections with a url func', (done) ->
    test.when 'GET', 'api-root/my/mock/url', (req) ->
      status: 200

    test.when 'GET', 'api-root/my/mock/func/url', (req) ->
      status: 200

    class MockCollection extends Collection
      model: MockModel
      url:   '/my/mock/url'

    class MockFuncCollection extends Collection
      model: MockModel
      url:   -> '/my/mock/func/url'

    collections =
      value:  MockCollection
      func:   MockFuncCollection

    load(collections, 'api-root').done ->
      done()

  it 'should not fetch lazy collections', (done) ->
    fetches = 0

    test.when 'GET', '/my/mock/url', (req) ->
      fetches++
      status: 200
      body: '{"id": "item-1"}'

    test.when 'GET', '/my/lazy/mock/url', (req) ->
      fetches++
      status: 200
      body: '{"id": "lazy-item-1"}'


    class RegularCollection extends Collection
      model:  MockModel
      url:    '/my/mock/url'

    class LazyCollection extends Collection
      model:  MockModel
      url:    '/my/lazy/mock/url'
      lazy:   true

    collectionTypes =
      regular:  RegularCollection
      lazy:     LazyCollection

    load(collectionTypes).done (collections) ->
      expect(fetches).to.equal 1
      expect(collections.regular.models).to.have.length 1
      expect(collections.lazy.models).to.have.length 0

      # Make sure _collections lookup populated on both collections
      expect(collections.regular._collections.lazy.models).to.have.length 0
      expect(collections.lazy._collections.regular.models).to.have.length 1

      done()
