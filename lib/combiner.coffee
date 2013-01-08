$ = require 'jqueryify2'

module.exports =
  combine: (deferreds) ->
    remaining = deferreds.length
    combined = $.Deferred()

    for d in deferreds
      do (d) ->
        d.done ->
          combined.notify(d)
          if --remaining <= 0
            combined.resolve(deferreds)

    combined
