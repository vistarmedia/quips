Deferred = require('jqueryify2').Deferred
Backbone = require 'backbone'

Controller = require 'controllers/controller'
LoginView  = require 'views/login/login_view'
NoticeView = require 'views/notice_view'
User       = require 'models/user'


class LoginController extends Controller
  layout: require 'templates/login/layout'

  views:
    '.login-view':         'loginView'
    '.login-view .notice': 'noticeView'

  events:
    'loginView.change':   'checkCredentials'

  routes:
    'login':    'login'
    'logout':   'logout'

  constructor: ->
    @whoami = User.fetch
    @auth   = User.authenticate

    @loginView  = new LoginView().render()
    @noticeView = new NoticeView().render()

    super

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

    @auth(credentials.email, credentials.password)
      .always(@loginView.enable)
      .done(@deferred.resolve)
      .fail((msg) => @noticeView.error(msg))


module.exports = LoginController
