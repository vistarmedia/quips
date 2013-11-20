_ = require 'underscore'

module.exports = (instance, attrs...) ->
  constructor = instance.constructor
  while constructor?
    for attr in attrs
      # Merge current attribute with parent attribute
      instance[attr] = _.defaults(
        _.result(instance, attr),
        _.result(constructor.__super__, attr))

    constructor = constructor?.__super__?.constructor
