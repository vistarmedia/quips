module.exports = (window) ->
  originalConfirm = window.confirm


  beforeEach ->
    window.confirm = -> true

  afterEach ->
    window.confirm = originalConfirm
