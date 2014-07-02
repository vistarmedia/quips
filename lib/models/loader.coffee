_ = require 'underscore'

combine = require('../lib/combiner').combine


_load = (collections, apiRoot) ->
  apiRoot or= ''

  for name, collection of collections
    collectionRoot = collection.apiRoot or apiRoot
    do (collectionRoot, collection) ->
      collection._origUrl = collection.url
      collection.url = ->
        collectionRoot + _.result(collection, '_origUrl')

_combine = (collections) ->

  combine((c.fetch() for n, c of collections when not c.lazy))
    .pipe(-> collections)
    .done ->
      for n, c of collections
        c._collections = collections
    .promise()


module.exports =

  loadAll: (collectionSet) ->

    allCollections = {}
    for apiRoot, collections of collectionSet
      _.extend(allCollections, collections)
      _load(collections, apiRoot)

    _combine allCollections

  load: (collections, apiRoot) ->
    _load(collections, apiRoot)
    _combine collections
