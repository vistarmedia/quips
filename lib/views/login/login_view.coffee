View = require '../view'
$    = require 'jqueryify'


class LoginView extends View
  template: ->
    throw('Must override this template')

  events:
    'submit form': '_login'

  elements:
    '[name=email]':    '$email'
    '[name=password]': '$password'
    '[type=submit]':   '$button'

  disable: ->
    @$('input, button').prop('disabled', true)
    @$button.addClass('pending')

  enable: =>
    @$el.find('input').prop('disabled', false)
    @$button.removeClass('pending')
    @$password.val('')
    @$email.focus()

  _login: (e) ->
    e?.preventDefault()
    credentials =
      email:    $.trim(@$email.val())
      password: @$password.val()
      opts:     @options

    @trigger('change', credentials)

module.exports = LoginView
