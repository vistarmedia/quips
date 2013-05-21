test   = require '../setup'
expect = require('chai').expect

format = require 'lib/format'


describe 'Format library', ->

  beforeEach ->
    test.create()

  afterEach ->
    test.destroy()

  it 'should format a date', ->
    date = '1890-05-23T12:00:00Z'
    expect(format.date(date)).to.equal '5/23/1890'

  it 'should return an empty string for invalid date', ->
    expect(format.date('JUNK!!!')).to.equal ''
    expect(format.date()).to.equal ''
    expect(format.date('')).to.equal ''

  it 'should format money', ->
    expect(format.money(10)).to.equal '$10.00'
    expect(format.money(0)).to.equal '$0.00'
    expect(format.money(90.78)).to.equal '$90.78'
    expect(format.money(78.679)).to.equal '$78.68'
    expect(format.money(352378.679)).to.equal '$352,378.68'
    expect(format.money()).to.equal '$0.00'
    expect(format.money(NaN)).to.equal '$0.00'
    expect(format.money(0.87)).to.equal '$0.87'

  it 'should format numbers', ->
    expect(format.number(352378)).to.equal '352,378'
    expect(format.number(0)).to.equal '0'
    expect(format.number()).to.equal '0'
    expect(format.number(NaN)).to.equal '0'
    expect(format.number(0.87)).to.equal '1'

  it 'should format decimal numbers', ->
    expect(format.decimalNumber(3852.378)).to.equal '3,852.38'
    expect(format.decimalNumber(0)).to.equal '0.00'
    expect(format.decimalNumber()).to.equal '0.00'
    expect(format.decimalNumber(NaN)).to.equal '0.00'
    expect(format.decimalNumber(0.873)).to.equal '0.87'

  it 'should format a boolean', ->
    expect(format.boolean(true)).to.equal 'Yes'
    expect(format.boolean(false)).to.equal 'No'
    expect(format.boolean(undefined)).to.equal ' - '

  it 'should format zip codes', ->
    expect(format.zipCode(12345)).to.equal '12345'
    expect(format.zipCode('12345-7890')).to.equal '12345-7890'
    expect(format.zipCode('00123')).to.equal '00123'
    expect(format.zipCode(1040)).to.equal '01040'
