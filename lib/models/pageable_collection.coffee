_ = require 'underscore'

Collection = require './collection'

# These are private utility methods. They don't depend on instance state
validateAndGetTotalPages = (state, totalRecords) ->
  unless _.isFinite(totalRecords) and
         _.isFinite(state.pageSize) and
         _.isFinite(state.currentPage)
    throw new TypeError("""Non-numeric error --
      totalRecords: #{totalRecords},
      pageSize: #{state.pageSize},
      currentPage: #{state.currentPage}""")

  if state.pageSize < 1
    throw new RangeError('pageSize must be >= 1')

  totalPages = Math.max(Math.ceil(totalRecords / state.pageSize), 1)
  if state.currentPage < 1 or (
    totalPages > 0 and state.currentPage > totalPages)
    throw new RangeError(
      "page must be 1 <= currentPage > totalPages. Got #{state.currentPage}")

  totalPages

defaultState = ->
  currentPage: 1
  pageSize: 25
  totalPages: null


class PageableCollection extends Collection

  constructor: (@fullCollection, options) ->
    @state = defaultState()
    if _.isFinite(options?.pageSize)
      @state.pageSize = options.pageSize
    @state.totalPages = validateAndGetTotalPages(@state, @fullCollection.length)

    super([])
    @fullCollection.on('add', @_addHandler, this)
    @fullCollection.on('remove', @_removeHandler, this)
    @fullCollection.on('reset', @_resetHandler, this)
    @fullCollection.on('sort', @_sortHandler, this)
    @getFirstPage()

  hasPrevious: -> @state.currentPage > 1
  hasNext: -> @state.currentPage < @state.totalPages
  getFirstPage: -> @getPage(1)
  getPreviousPage: -> @getPage(@state.currentPage - 1)
  getNextPage: -> @getPage(@state.currentPage + 1)
  getLastPage: -> @getPage(@state.totalPages)
  getNumberOfPages: -> @state.totalPages
  getCurrentPageNumber: -> @state.currentPage

  getPage: (pageNum) ->
    unless _.isFinite(pageNum)
      throw new TypeError("Non-numeric pageNum: #{pageNum}")

    oldCurrentPage = @state.currentPage
    @state.currentPage = pageNum
    # Make sure this is a valid page number
    validateAndGetTotalPages(@state, @fullCollection.length)
    pageStart = (@state.currentPage - 1) * @state.pageSize
    pageModels =
      if @fullCollection.length > 0
        @fullCollection.models.slice(pageStart, pageStart + @state.pageSize)
      else
        []

    @reset(pageModels)
    @trigger('current_page_changed') unless @state.currentPage is oldCurrentPage

  setSorting: (order, sortValue) ->
    @fullCollection.setSorting(order, sortValue)

  _addHandler: (model) ->
    oldTotalPages = @state.totalPages
    @state.totalPages = validateAndGetTotalPages(@state, @fullCollection.length)
    @_totalPagesChanged(oldTotalPages)
    addedIndex = @fullCollection.indexOf(model)
    pageStart = (@state.currentPage - 1) * @state.pageSize
    pageEnd = pageStart + @state.pageSize
    if addedIndex >= pageStart and addedIndex < pageEnd
      pageIndex = addedIndex - pageStart
      @add(model, at: pageIndex)
      if @length > @state.pageSize
        @remove(@at(@state.pageSize))
    else if addedIndex < pageStart and @state.currentPage > 1
      @add(@fullCollection.at(pageStart), at: 0)
      # Remove the last item if the item we added makes the page too large
      if @length > @state.pageSize
        @remove(@at(@state.pageSize))
    @trigger('sort')

  _removeHandler: (model, collection, options) ->
    state = _.extend(_.clone(@state), currentPage: 1)
    oldTotalPages = @state.totalPages
    @state.totalPages = validateAndGetTotalPages(state, @fullCollection.length)
    @_totalPagesChanged(oldTotalPages)
    if @state.currentPage > @state.totalPages
      return @getPage(@state.totalPages)
    pageStart = (@state.currentPage - 1) * @state.pageSize
    pageEnd = pageStart + @state.pageSize
    removedIndex = options.index
    if removedIndex >= pageStart and removedIndex < pageEnd
      @remove(model)
    else if removedIndex < pageStart
      @remove(@at(0))

    if oldTotalPages > @state.currentPage and @length < @state.pageSize
      nextModel = _(@fullCollection.slice(pageEnd - 1)).find (m) =>
        not @contains(m)
      if nextModel? then @push(nextModel)

  _resetHandler: ->
    state = _.extend(_.clone(@state), currentPage: 1)
    oldTotalPages = @state.totalPages
    @state.totalPages = validateAndGetTotalPages(state, @fullCollection.length)
    @_totalPagesChanged(oldTotalPages)
    if @state.currentPage > @state.totalPages
      @getPage(@state.totalPages)
    @getPage(@state.currentPage)

  _sortHandler: (collection, options) ->
    @getPage(@state.currentPage) unless options?.add

  _totalPagesChanged: (oldTotalPages) ->
    @trigger('total_pages_changed') unless oldTotalPages is @state.totalPages


module.exports = PageableCollection
