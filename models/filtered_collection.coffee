Collection = require './collection'


# Creates a mirroed copy of a collection that filters can be appiled to. It
# should keep itself in sync with the given collection. When model instances
# transition from shown to filtered, a "remove" event will be triggered. In
# the other direction, the event will be "add"
class FilteredCollection extends Collection
  constructor: (@collection) ->
    super()
    @model = @collection.model

    @filters = {}
    @collection.on('add',     @addUnfiltered, this)
    @collection.on('remove',  @remove, this)
    @collection.on('reset',   @collectionReset, this)
    @reset(@collection.models)

  collectionReset: (c) ->
    @collection = c
    @reset([])
    @update()

  addUnfiltered: (model) ->
    if @isValid(model) then @add(model)

  removeFilter: (name) ->
    delete @filters[name]
    @update()

  addFilter: (name, filter) ->
    @filters[name] = filter
    @update()

  isValid: (model) ->
    for _, filter of @filters
      if not filter(model) then return false
    return true

  # Perform an internal update, adding models which are now valid and removing
  # models which are now invalid.
  update: =>
    for model in @collection.models
      # When the model is valid, see if we hold a copy of it. If so, do
      # nothing. Otherwise, add it.
      if @isValid(model)
        if not @get(model.id) then @add(model)

      # When the model is invalid, see if a copy is held in this colleciton.
      # If so, remove it. Otherwise, do nothing.
      else
        if @get(model.id) then @remove(model)

    @trigger('change')


module.exports = FilteredCollection
