$ = require 'jqueryify'

module.exports =
  combine: (deferreds) ->
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
