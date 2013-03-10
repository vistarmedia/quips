$ = require 'jqueryify2'
combine = require('../lib/combiner').combine

root = ''


module.exports =

  load: (collectionTypes, apiRoot) ->
    apiRoot or= ''
    collections = {}

    for name, collectionType of collectionTypes
      collection = new collectionType
      if $.isFunction(collection.url)
        urlFunc = collection.url
        collection.url = do ->
          apiRoot + urlFunc()
      else
        collection.url = apiRoot + collection.url
      collections[name] = collection

    root = apiRoot

    combine((c.fetch() for _, c of collections when not c.lazy))
      .pipe(-> collections)
      .done ->
        for _, c of collections
          c._collections = collections
      .promise()


  getApiRoot: ->
    root
