View       = require 'views/view'


class LoginView extends View
  template: require 'templates/login/view'

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
      email:    @$email.val()
      password: @$password.val()

    @trigger('change', credentials)

module.exports = LoginView
