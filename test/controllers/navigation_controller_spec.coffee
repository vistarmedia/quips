test      = require '../setup'
expect    = require('chai').expect
$         = require 'jqueryify2'
Backbone  = require 'backbone'

User                 = require 'models/user'
NavigationController = require 'controllers/navigation_controller'


describe 'Navigation Controller', ->

  beforeEach ->
    test.create()

    @history = new Backbone.History
    @root = $('<div>')
    @user = new User('User Name', 'email')
    @nav  = new NavigationController(@user, el: @root, history: @history)

  afterEach ->
    @nav.destroy()
    @history.stop()
    test.destroy()

  it 'should render nothing until activated', ->
    expect(@root.html()).to.equal ''

    @nav.activate()
    expect(@root.html()).to.include 'User Name'
