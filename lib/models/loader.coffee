$ = require 'jqueryify'
_ = require 'underscore'

combine = require('../lib/combiner').combine


_load = (collectionTypes, apiRoot, opts, collections) ->
  apiRoot or= ''

  for name, collectionType of collectionTypes
    collection = new collectionType(opts)
    collectionRoot = collection.apiRoot or apiRoot
    do (collectionRoot, collection) ->
      collection._origUrl = collection.url
      collection.url = ->
        collectionRoot + _.result(collection, '_origUrl')
      collections[name] = collection

_combine = (collections) ->

  combine((c.fetch() for n, c of collections when not c.lazy))
    .pipe(-> collections)
    .done ->
      for n, c of collections
        c._collections = collections
    .promise()


module.exports =

  loadAll: (collectionTypeSet, opts) ->
    collections = {}

    for apiRoot, collectionTypes of collectionTypeSet
      _load(collectionTypes, apiRoot, opts, collections)

    _combine collections

  load: (collectionTypes, apiRoot, opts) ->
    collections = {}
    _load(collectionTypes, apiRoot, opts, collections)
    _combine collections
