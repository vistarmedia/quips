jQuery = require 'jqueryify2'

collectionTypes = {}

module.exports = (apiRoot) ->
  apiRoot or= ''
  collections = {}

  for name, collectionType of collectionTypes
    collection = new collectionType
    collection.url = apiRoot + collection.url
    collections[name] = collection

  jQuery.when((c.fetch() for _, c of collections)...)
    .pipe(-> collections)
    .done ->
      for _, c of collections
        c._collections = collections
    .promise()

module.exports.collectionTypes = collectionTypes
