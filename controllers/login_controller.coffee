Deferred = require('jqueryify2').Deferred
Backbone = require 'backbone'

Controller = require './controller'
LoginView  = require '../views/login/login_view'
NoticeView = require '../views/notice_view'
User       = require '../models/user'


class LoginController extends Controller
  views:
    '.login-view':         'loginView'
    '.login-view .notice': 'noticeView'

  events:
    'loginView.change':   'checkCredentials'

  routes:
    'login':    'login'
    'logout':   'logout'

  constructor: (layout, LoginViewClass, opts) ->
    @layout = layout
    @whoami = User.fetch
    @auth   = User.authenticate

    @loginView  = new LoginViewClass().render()
    @noticeView = new NoticeView().render()

    super(opts)

  login: ->
    @deferred = new Deferred
    @whoami()
      .done((user) => @deferred.resolve(user))
      .fail((reason) => @activate())

    @deferred.promise()

  logout: ->
    User.current?.logout().done =>
      document.location = '/'

  checkCredentials: (credentials) =>
    @loginView.disable()

    @auth(credentials.email, credentials.password, credentials.opts)
      .always(@loginView.enable)
      .done(@deferred.resolve)
      .fail((msg) => @noticeView.error(msg))


module.exports = LoginController
