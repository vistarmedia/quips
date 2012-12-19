require './stickysidebar.jquery'

available = ->
  document.documentElement?

module.exports =
  stickify: ($el) ->
    if available()
      $el.stickySidebar(padding: 0, speed: 0)

  unstickify: ($el) ->
    if available()
      $el.stickySidebar("destroy")
