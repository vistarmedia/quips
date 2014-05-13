_        = require 'underscore'
jQuery   = require 'jqueryify'
Deferred = jQuery.Deferred
JSON     = require 'json2ify'
moment   = require 'moment'

Format  = require './format'
View    = require '../views/view'


class FormView extends View
  errorTemplate: ->
    throw Error('Must override errorTemplate')

  constructor: (@model, opts) ->
    @deferred = new Deferred()

    @events or= {}
    @events['submit form'] = 'save'
    super(@model)

    if opts?.fieldClass?
      @fieldClass = opts.fieldClass

    if opts?.controlsClass?
      @controlsClass = opts.controlsClass

  save: (e) ->
    e?.preventDefault()
    @_hideErrors()
    elements = @_disableForm()

    local = new Deferred
    local.always => @_enableElements(elements)

    onError = (errors) =>
      @_showErrors(errors)
      local.reject(errors)
      @deferred.notify(errors)
      @trigger('failed', errors)

    onSuccess = =>
      local.resolve(@model)
      @deferred.notify()
      @deferred.resolve(@model)
      @trigger('saved')

    try
      update = @_getUpdate()
      @model.save(update, wait: true)
        .done(onSuccess)
        .fail (resp) ->
          respJson = if resp.responseText
            JSON.parse(resp.responseText)
          else
            {}

          onError(respJson)

    catch errors
      onError(errors)

    local

  render: ->
    super
    @_populateForm()
    this

  _hideErrors: ->
    @$el.find('ul.errors').remove()
    @$el.find('.error').removeClass('error')

  _showErrors: (errs) ->
    for name, errors of errs
      field = @$el.find("[name=#{name}]")

      errorTemplate = @errorTemplate(errors: errors)

      if @controlsClass
        field.closest(".#{@controlsClass}").append(errorTemplate)
      else
        field.last().after(errorTemplate)

      parent = if @fieldClass
        field.closest(".#{@fieldClass}") or field.parent()
      else
        field.parent()

      parent.addClass('error')

  _enableElements: (elements) ->
    elements.prop('disabled', false)

  _disableForm: ->
    enabledElements = @$el.find(':input:not(:disabled)')
    enabledElements.prop('disabled', true)
    enabledElements

  _populateForm: ->
    for name, field of _.result(this, 'fields')
      value = @model.get(name)
      el = @$el.find("[name=#{name}]")
      field.set(el, value)

  _getUpdate: ->
    update = {}
    errors = {}
    for name, field of _.result(this, 'fields')
      el = @$el.find("[name=#{name}]")
      try
        update[name] = field.get(el)
      catch error
        errors[name] = [error.message]

    unless _.isEmpty(errors)
      throw errors

    return update


dateToString = (date) ->
  if _.isNaN(date.getTime())
    throw TypeError('Invalid Date')
  moment(date).toISOString().split('.')[0] + 'Z'

stringField =
  get: (el) -> el.val()
  set: (el, value) -> el.val(value)


intField =
  get: (el, defaultValue) ->
    stripped = el.val().replace(/\,/g, '')
    i = parseInt(stripped, 10)
    if _.isNaN(i)
      return defaultValue if defaultValue?
      throw TypeError('Invalid Number')
    i

  set: (el, value) ->
    int = parseInt(value, 10)
    if _.isNaN(int)
      int = 0
    el.val(Format.commafy(int))

nonGroupedIntField =
  get: (el, defaultValue) ->
    stripped = el.val().replace(/\,/g, '')
    i = parseInt(stripped, 10)
    if _.isNaN(i)
      return defaultValue if defaultValue?
      throw TypeError('Invalid Number')
    i

  set: (el, value) ->
    int = parseInt(value, 10)
    if _.isNaN(int)
      int = 0
    el.val(int)

floatField =
  get: (el, defaultValue) ->
    float = parseFloat(el.val())
    if _.isNaN(float)
      return defaultValue if defaultValue?
      throw TypeError('Invalid Number')
    float

  set: (el, value) ->
    float = parseFloat(value)
    if _.isNaN(float)
      float = 0
    el.val(float)


moneyField =
  get: (el, defaultValue) ->
    stripped = el.val().replace(/\,/g, '')
    money = parseFloat(stripped)
    if _.isNaN(money)
      return defaultValue if defaultValue?
      throw TypeError('Invalid Number')
    money.toFixed(2)

  set: (el, value) ->
    moneyFloat = parseFloat(value)
    if _.isNaN(moneyFloat)
      moneyFloat = 0
    el.val(Format.commafy(moneyFloat.toFixed(2)))


boolField =
  get: (el) -> el.prop('checked')
  set: (el, value) -> el.prop('checked', value)


dateField =
  get: (el) ->
    dateToString(new Date(el.val()))

  set: (el, value) ->
    date = if value? then new Date(value) else Date.now()
    el.val(moment(date).format('MM/DD/YYYY'))


populateTimes = (select, isEnd) ->
  return if select.children().length
  mins = if isEnd then '59' else '00'

  for tt in ['AM', 'PM']
    for hour in [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      label = "#{hour}:#{mins} #{tt}"
      jQuery('<option>')
        .attr('value', label)
        .text(label)
        .appendTo(select)
        .prop('selected', hour is 11 and isEnd)


dateTimeField =
  get: (el) ->
    dateStr = el.filter('.date').val()
    timeStr = el.filter('.time').val() or ''
    if dateStr is '' or timeStr is ''
      return null

    dateToString(new Date("#{dateStr} #{timeStr}"))

  set: (el, value) ->
    timeEl = el.filter 'select.time'
    populateTimes(timeEl, false)
    return unless value?
    date = new Date(value)
    if _.isNaN(date.getTime())
      throw new TypeError('Invalid date string')

    el.filter('.date').val(moment(date).format('MM/DD/YYYY'))
    timeEl.val(moment(date).format('h:00 A'))


endDateTimeField =
  get: (el) ->
    dateStr = el.filter('.date').val()
    timeStr = el.filter('.time').val() or ''
    if dateStr is '' or timeStr is ''
      return null

    dateToString(new Date("#{dateStr} #{timeStr}"))

  set: (el, value) ->
    timeEl = el.filter 'select.time'
    populateTimes(timeEl, true)
    return unless value?
    date = new Date(value)
    if _.isNaN(date.getTime())
      throw new TypeError('Invalid date string')

    el.filter('.date').val(moment(date).format('MM/DD/YYYY'))
    timeEl.val(moment(date).format('h:59 A'))


module.exports =
  FormView:           FormView
  stringField:        stringField
  intField:           intField
  nonGroupedIntField: nonGroupedIntField
  floatField:         floatField
  moneyField:         moneyField
  boolField:          boolField
  dateField:          dateField
  dateTimeField:      dateTimeField
  endDateTimeField:   endDateTimeField
