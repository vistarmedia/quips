_ = require 'underscore'

bind = ->
    throw Error('bind() is deprecated, use on()')

register = (events, callback, to, from) ->
  unless to? then throw new Error('context required')
  (to._bindings or= []).push
    events:   events
    callback: callback
    context:  from

unregister = (instance) ->
  for b in (instance._bindings or [])
    b.context.off(b.events, b.callback)

module.exports =
  bind: bind

  register: register

  unregister: unregister

  track: (cls) ->
    return cls if cls._events_tracked

    cls::_onOrig = cls::on
    cls::bind = bind
    cls::on = (events, callback, to) ->
      register(events, callback, to, this)
      this._onOrig(arguments...)

    cls::unregister = -> unregister(this)
    cls._events_tracked = true

    cls
