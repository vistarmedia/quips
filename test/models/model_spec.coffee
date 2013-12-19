require '../setup'
expect  = require('chai').expect

Model = require 'models/model'

describe 'Models', ->

  it 'should extend the default dict', ->
    class MahModel extends Model
      extraAttributes: ->
        greeting: "Hi, #{@get('name')}!"

    params = new MahModel(name: 'Bobby').json()
    expect(params.name).to.equal 'Bobby'
    expect(params.greeting).to.equal 'Hi, Bobby!'

  it 'should return a callable dict', ->
    class Simple extends Model
    model = new Simple(age: 23)

    params = model.json()
    expect(params.age).to.equal (23)

    withExtra = params.extend(name: 'Frank').extend(face: 'huge')
    expect(params.age).to.equal (23)
    expect(params.name).to.equal ('Frank')
    expect(params.face).to.equal ('huge')
