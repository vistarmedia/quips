_         = require 'underscore'
Deferred  = require('jqueryify2').Deferred

Controller        = require './controller'


class FormController extends Controller
  layout: _.template('<div class="form-view"></div>')

  views:
    '.form-view': 'formView'

  constructor: (@formView, opts) ->
    super(opts)

  save: ->
    @activate()
    @formView.deferred


module.exports = FormController
