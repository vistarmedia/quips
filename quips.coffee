module.exports =
  # Models
  Model:  require 'quips/models/model'
  User:   require 'quips/models/user'

  # Collections
  Collection:         require 'quips/models/collection'
  FilteredCollection: require 'quips/models/filtered_collection'

  # Views
  View:           require 'quips/views/view'
  DetailView:     require 'quips/views/detail_view'
  ListView:       require('quips/views/list_view').ListView
  LoginView:      require 'quips/views/login/login_view'
  NavigationView: require 'quips/views/navigation_view'
  NoticeView:     require 'quips/views/notice_view'
  RowView:        require('quips/views/list_view').RowView

  # Controllers
  Controller:           require 'quips/controllers/controller'
  FormController:       require 'quips/controllers/form_controller'
  LoginController:      require 'quips/controllers/login_controller'
  NavigationController: require 'quips/controllers/navigation_controller'

  # Forms
  FormView:       require('quips/lib/forms').FormView
  stringField:    require('quips/lib/forms').stringField
  intField:       require('quips/lib/forms').intField
  moneyField:     require('quips/lib/forms').moneyField
  boolField:      require('quips/lib/forms').boolField
  dateField:      require('quips/lib/forms').stringField
  dateTimeField:  require('quips/lib/forms').dateTimeField

  # Formatters
  formatters:
    date:     require('quips/lib/format').date
    dateTime: require('quips/lib/format').dateTime
    boolean:  require('quips/lib/format').boolean
    money:    require('quips/lib/format').money
    number:   require('quips/lib/format').number

  # Test
  ChaiExtensions: require 'quips/test/lib/chai_extensions'
  MockHttpServer: require('quips/test/lib/mock_server').MockHttpServer
