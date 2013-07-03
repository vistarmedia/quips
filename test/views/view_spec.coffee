test    = require '../setup'
expect  = require('chai').expect

Backbone  = require 'backbone'
$         = require 'jqueryify'
_         = require 'underscore'

View  = require 'views/view'
Model = require 'models/model'


describe 'View', ->

  beforeEach ->
    test.create()

  afterEach ->
    test.destroy()

  it 'should have a DOM element', ->
    class StaticView extends View
      tagName:    'h1'
      className:  'party'

      render: ->
        @$el.text 'Bonjour'
        this

    view = new StaticView().render()
    body = $('<div>').append(view.el).html()
    expect(body).to.equal '<h1 class="party">Bonjour</h1>'

  it 'should be able to render a template', ->
    class TemplateView extends View
      template: require './test_template'

      render: ->
        body = @template name: 'frank'
        @$el.empty().append(body)
        this

    view = new TemplateView().render()
    expect(view.$el.html()).to.include '<h1 class="party">Hello, frank!</h1>'

  it 'should populate child views', ->
    root = $('<div></div>')

    class ChildView extends View
      template: -> "hello world"

    class TemplateView extends View
      views:
        '.child-view': 'childView'

      template: require './test_template'

      constructor: ->
        @childView = new ChildView().render()
        super

    view = new TemplateView(el: root).render()
    expect(view.$el.html()).to.include 'hello world'

  it 'should be able to use views if it is a function', ->
    root = $('<div></div>')

    class ChildView extends View
      template: -> "hello world"

    class TemplateView extends View
      views: ->
        if(true)
          '.child-view': 'childView'
        else
          {}

      template: require './test_template'

      constructor: ->
        @childView = new ChildView().render()
        super

    view = new TemplateView(el: root).render()
    expect(view.$el.html()).to.include 'hello world'

  describe 'removal', ->

    it 'should not leak events', ->
      class NoLeaks extends View
        constructor: (@model) ->
          super
          @model.on 'reset', @render, this

      model = new Model()
      expect(model._events).to.be.undefined
      view = new NoLeaks(model)

      listeners = -> _.flatten((v for k, v of model._events))
      expect(do listeners).to.have.length 1

      view.remove()
      expect(do listeners).to.have.length 0

    it 'should clean up its childrens', ->
      removesCalled = 0
      class ChildView extends View
        remove: ->
          super
          removesCalled++

        render: ->
          @html 'WAAAA'

      child = new ChildView()
      child.render()

      class ParentView extends View
        render: ->
          @append child

      parent = new ParentView().render()
      parent.remove()

      expect(removesCalled).to.equal 1

  it 'should populate element fields', ->
    class WithElements extends View
      template: require './test_form'
      elements:
        'input[name=email]':    '$email'
        'input[name=password]': '$password'

    view = new WithElements
    expect(view.$email).to.not.exist

    view.render()
    view.$('input[type=password]').val('same ref')
    expect(view.$email.val()).to.equal 'zip!'
    expect(view.$password.val()).to.equal 'same ref'

  it 'should be able to append to a specific element', ->
    class SomeView extends View
      template: $('<div>')

    someView = new SomeView()
    domEl = $('<div>')

    expect(domEl.find('.hello')).to.have.length 0

    someView.append($("<p class='hello'>Hello World</p>"), domEl)

    expect(someView.$el.find('.hello')).to.have.length 0
    expect(domEl.find('.hello')).to.have.length 1

  it 'should setup all tables', ->
    class TableView extends View
      template: require './test_template'

    view = new TableView().render()
    expect(view.$el.find('.row')).to.have.length 4
    expect(view.$el.find('.row:nth-child(odd)')).to.have.length 2

  it 'should be able to extend a parent views events', ->
    class ParentView extends View
      template: -> """
        <div></div>
        <a></a>
        <span></span>
      """
      events:
        'click a': -> @string += 'Test'

      string: ""

    class FirstChildView extends ParentView
      events: ->
        'click div': -> @string += ' extends'

    class SecondChildView extends FirstChildView
      events:
        'click span': -> @string += ' events'

    view = new SecondChildView().render()
    view.$el.find('a').click()
    view.$el.find('div').click()
    view.$el.find('span').click()
    expect(view.string).to.equal 'Test extends events'
