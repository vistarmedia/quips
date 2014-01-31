require '../setup'

expect  = require('chai').expect
{all, combine, settled} = require 'lib/combiner'
$       = require 'jqueryify'


describe 'deferreds', ->
  describe '#combine', ->

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

  describe '#settled', ->

    it 'should notify the number of pending promises', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferred1.resolve()

      subject = settled([deferred1, deferred2])

      subject.progress (msg) ->
        expect(msg).to.equal 1
        done()

    it 'should resolve when all promises have a non-pending state', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]

      collection = settled(deferreds)

      collection.progress (msg) ->
        if msg is 2
          deferred3 = $.Deferred()
          deferreds.push(deferred3)
          deferred3.resolve()
          d.reject() for d in deferreds when d.state() is 'pending'

      collection.done (deferreds) ->
        rejected = (d for d in deferreds when d.state() is 'rejected')
        resolved = (d for d in deferreds when d.state() is 'resolved')
        expect(rejected.length).to.equal 2
        expect(resolved.length).to.equal 1
        done()

  describe '#all', ->
    it 'should resolve if all of the deferreds are resolved', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]
      d.resolve() for d in deferreds

      all(deferreds)
        .done -> done()

    it 'should reject if all of the deferreds are rejected', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]
      d.reject() for d in deferreds

      all(deferreds)
        .fail -> done()

    it 'should reject if any of the deferreds are rejected', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]

      deferred1.resolve()
      deferred2.reject()

      all(deferreds)
        .fail -> done()

    it 'should reject with failed deferreds', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]

      deferred1.resolve()
      deferred2.reject()

      all(deferreds)
        .fail (failedDeferreds) ->
          expect(failedDeferreds).to.include deferred2
          expect(failedDeferreds).not.to.include deferred1
          done()

    it 'should reject if all of the deferreds become rejected', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]

      all(deferreds)
        .progress (msg) ->
          if msg is 2
            d.reject() for d in deferreds
        .fail -> done()

    it 'should resolve if all of the deferreds become resolved', (done) ->
      deferred1 = $.Deferred()
      deferred2 = $.Deferred()
      deferreds = [deferred1, deferred2]

      all(deferreds)
        .progress (msg) ->
          if msg is 2
            d.resolve() for d in deferreds
        .done -> done()
