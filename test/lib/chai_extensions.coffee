module.exports = (chai, utils) ->
  inspect = utils.inspect
  flag    = utils.flag

  chai.Assertion.addMethod 'class', (className) ->
    @assert flag(this, 'object').hasClass(className),
      'expected #{this} to have class #{exp}',
      'expected #{this} not to have class #{exp}',
      className

  chai.Assertion.addMethod 'val', (expected) ->
    value = flag(this, 'object').val()

    @assert value is expected,
      'expected #{this} to have value #{exp}, but got #{act}',
      'expected #{this} not to have value #{exp}',
      expected, value

  chai.Assertion.addMethod 'element', (selector) ->
    obj = flag(this, 'object')
    @assert obj.find(selector).length > 0,
      'expected #{this} to have element #{exp}',
      'expected #{this} to not have element #{exp}',
      selector

  chai.Assertion.addMethod 'text', (expected) ->
    value = flag(this, 'object').text()

    @assert value is expected,
      'expected #{this} to have text #{exp}, but got #{act}',
      'expected #{this} not to have text #{exp}',
      expected, value
