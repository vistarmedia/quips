View = require './view'


class NoticeView extends View
  levels:     ['info', 'warn', 'error', 'pending']

  constructor: ->
    super

    for level in @levels
      do (level) =>
        @[level] = (message) -> @_set(level, message)

  reset: ->
    @$el.attr('class', '').empty()

  _set: (level, message) ->
    @_message = message
    @$el.attr('class', "notice-view #{level}")
        .text(message)

  render: ->
    this


module.exports = NoticeView
