$ = require 'jqueryify'


_resolvedAndRejected = (deferreds) ->
  resolved = (d for d in deferreds when d.state() is 'resolved')
  rejected = (d for d in deferreds when d.state() is 'rejected')
  [resolved, rejected]

_pending = (deferreds) ->
  (d for d in deferreds when d.state() is 'pending')

combine = (deferreds) ->
  remaining = deferreds.length
  combined = $.Deferred()

  for d in deferreds
    do (d) ->
      d.fail(combined.reject)
       .done ->
        combined.notify(d)
        if --remaining <= 0
          combined.resolve(deferreds)
  combined

settled = (deferreds) ->
  combined = $.Deferred()
  remaining = deferreds.length

  combined.notify(_pending(deferreds).length)

  for d in deferreds
    d.always ->
      if --remaining > 0
        combined.notify(remaining)
      else
        combined.resolve(deferreds)
  combined

all = (deferreds) ->
  deferred  = $.Deferred()
  settled(deferreds)
    .done (deferreds) ->
      [resolved, rejected] = _resolvedAndRejected(deferreds)
      if resolved.length > 0 and rejected.length is 0
        deferred.resolve(deferreds)
      else
        deferred.reject(rejected)
    .progress(deferred.notify)
  deferred


module.exports = {combine, settled, all}
