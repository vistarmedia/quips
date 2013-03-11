test = require '../setup'

expect  = require('chai').expect
combine = require('lib/combiner').combine
$       = require 'jqueryify'

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

  it 'should propagate the first error', (done) ->
    willSucceed = $.Deferred()
    willFail    = $.Deferred()

    combined = combine([willSucceed, willFail])
      .fail (reason) ->
        expect(reason).to.equal 'cuz'
        done()

    willFail.reject 'cuz'

    expect(willSucceed.state()).to.equal 'pending'
    expect(willFail.state()).to.equal 'rejected'
    expect(combined.state()).to.equal 'rejected'

    willSucceed.resolve 'gooies'

    expect(willSucceed.state()).to.equal 'resolved'
    expect(willFail.state()).to.equal 'rejected'
    expect(combined.state()).to.equal 'rejected'

describe 'jQuery deferreds', ->
  beforeEach ->
    @state = test.create()

  afterEach ->
    @state.destroy()

  it 'should notify of failures', (done) ->
    deferred = $.Deferred()
    promise  = deferred.promise()

    promise.fail (reason) ->
      expect(promise.state()).to.equal 'rejected'
      expect(reason).to.equal "Ain't nobody got time for that"
      done()

    deferred.reject "Ain't nobody got time for that"

  it 'should expose state', ->
    willFail    = $.Deferred()
    willFail.reject 'cuz'
    expect(willFail.state()).to.equal 'rejected'
