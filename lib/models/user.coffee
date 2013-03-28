$     = require 'jqueryify'
JSON  = require 'json2ify'


authUrl = '/session/'


class User
  constructor: (@name, @email) ->

  logout: ->
    $.ajax(type: 'DELETE', url: authUrl).done ->
      User.current = null

  json: ->
    name:   @name
    email:  @email

  # Sets a root API url to use for authenication. All authentication will work
  # if omitted, by it will always be used after its been set.
  @authenticateAgainst: (rootUrl) ->
    return unless rootUrl?
    authUrl = rootUrl + '/session/'

  # Given an email and password autentication, return the user in question, or
  # an error (which always indicates that the credentials cannot be validated)
  @authenticate: (email, password, opts) ->
    data = email: email, password: password
    if opts?
      $.extend(data, opts)

    resp = $.ajax
      type:         'POST'
      dataType:     'json'
      contentType:  'application/json'
      url:          authUrl
      data:         JSON.stringify(data)

    resp.pipe(User.fromResponse, -> 'Invalid Login')
      .done((user) -> User.current = user)

  # Ping /session/ to see if we're already logged in. This will retern a deferrand
  # who's `done` will be handed the current user, and who's `fail` will have the
  # response from the server.
  @fetch: ->
    $.getJSON(authUrl).pipe(User.fromResponse)
      .done((user) -> User.current = user)

  @fromResponse: (json) ->
    new User(json.name, json.email)


module.exports = User
