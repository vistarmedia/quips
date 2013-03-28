require './stickysidebar.jquery'

available = ->
  document.documentElement?

module.exports =
  stickify: ($el, opts) ->
    if available()
      $el.stickySidebar
        padding: opts?.padding or 0
        speed: opts?.speed or 0

  unstickify: ($el) ->
    if available()
      $el.stickySidebar("destroy")
