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

  it 'should propage the first error', (done) ->
    willSucceed = $.Deferred()
    willFail    = $.Deferred()

    combined = combine([willSucceed, willFail])
      .fail (reason) ->
        expect(reason).to.equal 'cuz'
        done()

    willFail.reject 'cuz'

    expect(willSucceed.isRejected()).to.be.false
    expect(willSucceed.isResolved()).to.be.false

    expect(willFail.isRejected()).to.be.true
    expect(willFail.isResolved()).to.be.false

    expect(combined.isRejected()).to.be.true
    expect(combined.isResolved()).to.be.false

    # We should be able to get results after a failure without error
    willSucceed.resolve 'gooies'

    expect(willSucceed.isResolved()).to.be.true
    expect(combined.isRejected()).to.be.true
