$ = require 'jqueryify2'

View = require 'views/view'


class SearchView extends View
  tagName:  'form'
  template: require 'templates/search_view'

  events:
    'keyup input':   '_onChange'

  _onChange: (e) ->
    e.preventDefault()
    query = $(e.currentTarget).val().toLowerCase()
    @trigger('change', query)


module.exports = SearchView
