test       = require '../setup'
expect     = require('chai').expect
$          = require 'jqueryify'

Controller = require 'controllers/controller'
View       = require 'views/view'


class EchoView extends View
  constructor: (@label) ->
    super()

  render: ->
    @html @label

class ClickView extends View
  className:  'click-view'

  events:
    'click':    'clicked'

  constructor: (@label) ->
    super()

  clicked: -> @trigger('clicked', this)

  render: ->
    @$el.empty().text(@label)
    this


class MyController extends Controller
  layout: require './test_controller_layout'

  views:
    '.slot1':   'viewOne'
    '.slot3':   'viewTwo'

  events:
    'viewOne.click':  'eatASandwich'
    'viewTwo.click':  'goForAWalk'

  constructor: ->
    @viewOne = new EchoView('View One').render()
    @viewTwo = new EchoView('View Two').render()

    @sandwichesEaten = 0
    @walksTaken = 0

    super

  eatASandwich: ->
    @sandwichesEaten++

  goForAWalk: ->
    @walksTaken++


class ClickController extends Controller
  layout: require './test_controller_layout'

  views:
    '.slot2':   'view'

  events:
    'view.clicked': 'clicked'

  constructor: (label, opts) ->
    @view = new ClickView(label).render()
    super(opts)
    @clicks = 0
    @destroyed = false
    @label = label

  clicked: -> @clicks++

  destroy: ->
    @destroyed = true
    super

class AaaView extends View
  template: require './test_aaa_template'

  removed: false

  remove: ->
    @removed = true
    super

class ZzzView extends View
  template: require './test_zzz_template'

  removed: false

  remove: ->
    @removed = true
    super


class WithNestedSubViews extends Controller
  layout: require './test_sort_template'

  views:
    '.zzz': 'zzz'
    '.aaa': 'aaa'

  constructor: ->
    @aaa = new AaaView().render()
    @zzz = new ZzzView().render()
    super


describe 'Controller', ->

  beforeEach ->
    test.create()
    @root = $('<div/>')
    @controller = new MyController el: @root

  afterEach ->
    test.destroy()
    @controller.destroy()

  it 'should place views in its layout', ->
    html = @controller._localEl.html()
    expect(html).to.include 'View One'
    expect(html).to.include 'View Two'

  it 'should respond to events of its views', ->
    expect(@controller.sandwichesEaten).to.equal 0
    expect(@controller.walksTaken).to.equal 0

    @controller.viewOne.trigger 'click'
    expect(@controller.sandwichesEaten).to.equal 1
    expect(@controller.walksTaken).to.equal 0

    @controller.viewTwo.trigger 'click'
    expect(@controller.sandwichesEaten).to.equal 1
    expect(@controller.walksTaken).to.equal 1

  it 'should activate on its `_pageEl` element', ->
    el = @controller._pageEl
    expect(el.html()).to.be.empty

    @controller.activate()
    expect(el.html()).to.not.be.empty
    expect(el.html()).to.include 'MyController'


  describe 'Two controllers sharing one element', ->
    beforeEach ->
      @controller1 = new ClickController('Controller One', el: @root)
      @controller2 = new ClickController('Controller Two', el: @root)

    afterEach ->
      @controller1.destroy()
      @controller2.destroy()

    it 'should allow the active controller to render', ->
      expect(@root.html()).to.equal ''

      @controller1.activate()
      expect(@root.html()).to.include 'Controller One'
      expect(@root.html()).to.not.include 'Controller Two'


      @controller2.activate()
      expect(@root.html()).to.not.include 'Controller One'
      expect(@root.html()).to.include 'Controller Two'

      @controller1.activate()
      expect(@root.html()).to.include 'Controller One'
      expect(@root.html()).to.not.include 'Controller Two'

    it 'should preserve DOM bindings between activations', ->
      @controller1.activate()
      expect(@controller1.clicks).to.equal 0

      expect(@root.find('.click-view').text()).to.equal 'Controller One'
      @root.find('.click-view').click()
      expect(@controller1.clicks).to.equal 1

      @controller1.activate()

      @root.find('.click-view').click()
      expect(@controller1.clicks).to.equal 2

  describe 'Controller with nested views', ->

    beforeEach ->
      test.create()
      @root = $('<div/>')
      @controller = new WithNestedSubViews el: @root

    afterEach ->
      test.destroy()
      @controller.destroy()

    it 'should load when lexographical', ->
      aaa = @controller._localEl.find('.aaa')
      expect(aaa.text()).to.include 'This is AAA'
      zzz = @controller._localEl.find('.aaa.zzz')
      expect(aaa.text()).to.include 'This is ZZZ'

    it 'should remove nested views on tear down', ->
      expect(@controller.aaa.removed).to.be.false
      expect(@controller.zzz.removed).to.be.false

      @controller.destroy()
      expect(@controller.aaa.removed).to.be.true
      expect(@controller.zzz.removed).to.be.true

  describe 'when tracking a child controller', ->

    it 'should track the reference', ->
      expect(@controller._child).to.not.be.defined

      @controller.trackNew(ClickController, 'First')
      expect(@controller._child).to.be.defined
      expect(@controller._child.label).to.equal 'First'

    it 'should clobber the old tracked controller', ->
      @controller.trackNew(ClickController, 'First')
      child = @controller._child
      expect(child.label).to.equal 'First'
      expect(child.destroyed).to.be.false

      @controller.trackNew(ClickController, 'Second')
      expect(@controller._child.label).to.equal 'Second'
      expect(child.destroyed).to.be.true

    it 'should clean up the child on activation', ->
      @controller.trackNew(ClickController, 'Subby')
      expect(@controller._child.destroyed).to.be.false

      @controller.activate()
      expect(@controller._child).to.not.exist

    it 'should clean up the child on destruction', ->
      @controller.trackNew(ClickController, 'Fizz')
      child = @controller._child

      expect(child.destroyed).to.be.false
      @controller.destroy()
      expect(child.destroyed).to.be.true
