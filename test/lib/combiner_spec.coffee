test = require '../setup'
expect = require('chai').expect
combine = require('lib/combiner').combine
$ = require 'jqueryify2'

describe 'Deferred combiner', ->
  beforeEach ->
    @state = test.create()

  afterEach ->
    @state.destroy()

  it 'should give progress on individual done calls', (done) ->
    d1 = $.Deferred()
    d2 = $.Deferred()

    notifs = 0
    combine([d1, d2])
      .progress ->
        notifs++
      .done ->
        expect(notifs).to.equal 2
        done()

    d1.resolve()
    d2.resolve()
