test   = require '../setup'
expect = require('chai').expect

Model = require 'models/model'

events = require 'lib/events'


describe 'Events', ->

  beforeEach ->
    @cls = class
      constructor: ->
        @bindsCalled = 0

      bind: ->
        @bindsCalled++

  it 'should add an `unregister` method', ->
    raw = new @cls
    expect(raw).to.not.respondTo 'unregister'

    events.track @cls
    tracked = new @cls
    expect(tracked).to.respondTo 'unregister'

  it 'should disallow `bind` calls', ->
    raw = new @cls
    raw.bind()
    expect(raw.bindsCalled).to.equal 1

    events.track @cls
    tracked = new @cls
    expect(tracked.bind).to.throw(Error, 'bind() is deprecated')

  it 'should track bindings on the callee', ->
    events.track @cls
    model = new Model()
    tracked = new @cls

    expect(tracked._bindings or []).to.have.length 0
    model.on('change', ((x) -> noop), tracked)
    expect(tracked._bindings or []).to.have.length 1
