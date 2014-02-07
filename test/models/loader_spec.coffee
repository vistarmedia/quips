require '../setup'
expect  = require('chai').expect
$       = require 'jqueryify'

Collection  = require 'models/collection'
Model       = require 'models/model'

load = require('models/loader').load


class MockModel extends Model

class MockCollection extends Collection
  model: MockModel
  url:   '/my/mock/url'


describe 'Model Loader', ->

  it 'should handle collections with a url func', (done) ->

    class MockFuncCollection extends Collection
      model: MockModel
      url:   -> '/my/mock/func/url'

    @server.when 'GET', 'api-root/my/mock/url', (req) ->
      status: 204

    @server.when 'GET', 'api-root/my/mock/func/url', (req) ->
      status: 204

    collections =
      value:  MockCollection
      func:   MockFuncCollection

    load(collections, 'api-root').done ->
      done()

  it 'should allow apiRoot to be overridden per collection', (done) ->

    class MockRootOverrideCollection extends Collection
      model:    MockModel
      url:      '/my/mock/url'
      apiRoot:  'new-root'

    collectionOneFetches = 0
    collectionTwoFetches = 0

    @server.when 'GET', 'api-root/my/mock/url', (req) ->
      collectionOneFetches++
      status: 204

    @server.when 'GET', 'new-root/my/mock/url', (req) ->
      collectionTwoFetches++
      status: 204

    collections =
      one: MockCollection
      two: MockRootOverrideCollection

    load(collections, 'api-root').done ->
      expect(collectionOneFetches).to.equal 1
      expect(collectionTwoFetches).to.equal 1
      done()

  describe 'when loading multiple collections with url functions', ->

    it "should make a request to each collection's url", (done) ->
      collectionOneFetches = 0
      collectionTwoFetches = 0

      @server.when 'GET', 'api-root/my/mock/func/url1', (req) ->
        collectionOneFetches++
        status: 204

      @server.when 'GET', 'api-root/my/mock/func/url2', (req) ->
        collectionTwoFetches++
        status: 204

      class FuncOneCollection extends Collection
        model: MockModel
        url:   -> '/my/mock/func/url1'

      class FuncTwoCollection extends Collection
        model: MockModel
        url:   -> '/my/mock/func/url2'

      collections =
        funcOne: FuncOneCollection
        funcTwo: FuncTwoCollection

      load(collections, 'api-root').done ->
        expect(collectionOneFetches).to.equal 1
        expect(collectionTwoFetches).to.equal 1
        done()

  it 'should not fetch lazy collections', (done) ->
    fetches = 0

    @server.when 'GET', '/my/mock/url', (req) ->
      fetches++
      status: 200
      body: '{"id": "item-1"}'

    @server.when 'GET', '/my/lazy/mock/url', (req) ->
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
