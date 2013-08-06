test    = require '../setup'
expect  = require('chai').expect
$       = require 'jqueryify'
JSON    = require 'json2ify'

Model = require 'models/model'
forms = require 'lib/forms'


class TestForm extends forms.FormView
  template:       require './form_view_spec_template'
  errorTemplate:  require './form_error'

  fields:
    name:             forms.stringField
    age:              forms.intField
    birthday:         forms.dateField
    someDateTime:     forms.dateTimeField
    gender:           forms.stringField
    olderThanAndrew:  forms.boolField
    youngerThanMark:  forms.intField


describe 'Form View', ->

  beforeEach ->
    test.create()
    @lilBilly = new Model
      name:             "Li'l Billy"
      age:              23
      gender:           'male'
      olderThanAndrew:  true
      youngerThanMark:  8
      someDateTime:     '2012-02-24 12:00 PM'

    @lilBilly.url = '/lils/billy'

    @form = new TestForm(@lilBilly).render()

  afterEach ->
    @form.remove()
    test.destroy()

  it 'should populate a form', ->
    nameField = @form.$el.find('input[name=name]')
    ageField = @form.$el.find('input[name=age]')
    olderThanAndrew = @form.$el.find('input[name=olderThanAndrew]')

    expect(nameField.val()).to.equal "Li'l Billy"
    expect(ageField.val()).to.equal '23'
    expect(olderThanAndrew.prop('checked')).to.be.true

  it 'should allow fields to be a function', ->
    class TestForm2 extends forms.FormView
      template:       require './form_view_spec_template'
      errorTemplate:  require './form_error'

      fields: ->
        name:             forms.stringField

    form = new TestForm2(@lilBilly).render()
    expect(form._getUpdate()['name']).to.equal "Li'l Billy"

  it 'should set a date', ->
    @lilBilly.set(birthday: '1991-02-24T04:22:34Z')
    form = new TestForm(@lilBilly).render()

    expect(form.$el.find('[name=birthday]').val()).to.equal '02/23/1991'

  it 'should come up with sane default dates', ->
    @lilBilly.set(birthday: undefined)
    form = new TestForm(@lilBilly).render()

    expect(form.$el.html()).to.not.include 'NaN'

  it 'should populate a select field', ->
    @lilBilly.set(gender: 'male')
    form = new TestForm(@lilBilly).render()
    expect(form.$el.find('select[name=gender]')).to.have.val 'male'

  it 'should submit the value of a select view', (done) ->
    test.when 'POST', '/lils/billy', (req) ->
      postData = $.parseJSON(req.requestText)
      expect(postData.gender).to.equal 'male'
      done()

    @lilBilly.set(gender: 'male')
    form = new TestForm(@lilBilly).render()
    form.$el.find('form').submit()


  describe 'when getting an update', ->

    it 'should return an update object', ->
      @form.$el.find('[name=name]').val('William')
      @form.$el.find('[name=age]').val('42')
      @form.$el.find('[name=olderThanAndrew]').prop('checked', true)

      update = @form._getUpdate()

      expect(update.name).to.equal 'William'
      expect(update.age).to.equal 42
      expect(update.olderThanAndrew).to.be.true

    it 'should return an update with a set date', ->
      @form.$el.find('[name=birthday]').val('04/22/1999 8:45:55 AM')
      update = @form._getUpdate()
      expect(update.birthday).to.equal '1999-04-22T13:45:55Z'

  describe 'when saving a form', ->

    it 'should post the update to the server', (done) ->
      test.when 'POST', '/lils/billy', (req) ->
        body: JSON.stringify
          age:  -1
          name: 'Steve'

      @form.$el.find('[name=name]').val('Steve')

      @form.save().done (result) =>
        expect(@lilBilly.get('age')).to.equal -1

        expect(result.get('name')).to.equal 'Steve'
        expect(result.get('age')).to.equal -1
        done()

    it 'should return errors from server', (done) ->
      test.when 'POST', '/lils/billy', (req) ->
        status: 400
        body:   JSON.stringify
          age: ['None uh yer beeswax!']

      @form.save().fail (errors) ->
        expect(errors.age).to.have.length 1
        expect(errors.age[0]).to.equal 'None uh yer beeswax!'
        done()

    it 'should handle error with empty response', (done) ->
      test.when 'POST', '/lils/billy', (req) ->
        status: 500

      @form.save().fail (errors) ->
        expect(errors).to.not.be.an.instanceof(SyntaxError)
        done()

    it 'should notify instance deferred on success', (done) ->
      test.when 'POST', '/lils/billy', (req) ->
        status: 204

      @form.deferred.progress ->
        done()

      @form.save()

    it 'should fire a saved event on success', (done) ->
      test.when 'POST', '/lils/billy', (req) ->
        status: 204

      @form.on('saved', (->
        done()), @form)

      @form.save()

    it 'should notify instance deferred on error', (done) ->
      test.when 'POST', '/lils/billy', (req) ->
        status: 400
        body:   JSON.stringify
          age: ['None uh yer beeswax!']

      @form.deferred.progress (errors) ->
        expect(errors.age).to.have.length 1
        expect(errors.age[0]).to.equal 'None uh yer beeswax!'
        done()

      @form.save()

    it 'should throw an exception with invalid input', ->
      @form.$el.find('[name=birthday]').val("HOW DO YOU USE THIS THING?")

      try
        @form._getUpdate()
        test.fail('Should have failed')
      catch errors
        expect(errors).to.not.be.empty
        expect(errors.birthday).to.have.length 1

        # On some node VMs, this will be the string "Invalid Date" on very
        # similar VMs (no difference I can detect) this may return "Invalid time
        # value"
        expect(errors.birthday[0]).to.include 'Invalid'

    it 'should throw an exception with invalid integer input', ->
      @form.$el.find('[name=age]').val('NOT AN AGE!!1!')

      try
        @form._getUpdate()
        test.fail('Should have failed')
      catch errors
        expect(errors['age']).to.have.length 1
        expect(errors['age'][0]).to.equal 'Invalid Number'

    describe 'and the input is invalid', ->

      beforeEach ->
        @form.$el.find('[name=age]').val('Not and age')

      it 'should fail on malformed input', (done) ->
        @form.save().fail (errors) ->
          expect(errors.age).to.have.length 1
          expect(errors.age[0]).to.equal 'Invalid Number'
          done()

      it 'should show errors on the form', (done) ->
        expect(@form.$el.html()).to.not.include 'Invalid Number'
        @form.save().fail =>
          expect(@form.$el.html()).to.include 'Invalid Number'
          done()

      it 'should add an error class to the containing div', (done) ->
        ageDiv = @form.$el.find('.age-div')
        expect(ageDiv.attr('class')).to.equal 'age-div'

        @form.save().fail =>
          ageDiv = @form.$el.find('.age-div')
          expect(ageDiv.attr('class')).to.include 'age-div'
          expect(ageDiv.attr('class')).to.include 'error'
          done()

      it 'should use opts when adding an error', (done) ->
        form = new TestForm(@lilBilly,
          fieldClass:     'field'
          controlsClass:  'controls').render()

        form.$el.find('[name=youngerThanMark]').val('Not a bool')
        ytmField = form.$el.find('.field.younger-than-mark')
        expect(ytmField).to.not.have.class 'error'
        expect(ytmField.find('.controls')).to.not.have.element 'ul.errors'

        form.save().fail =>
          expect(ytmField).to.have.class 'error'
          expect(ytmField.find('.controls')).to.have.element 'ul.errors'
          expect(ytmField.find('.other-container'))
            .to.not.have.element 'ul.errors'
          done()

      it 'should remove errors when the problem is fixed', (done) ->
        test.when 'POST', '/lils/billy', (req) ->
          body: JSON.stringify(age: 18)

        res = @form.save().pipe null, (errs) =>
          root = @form.$el
          expect(root.find('.age-div.error')).to.have.length 1
          expect(root.find('ul.errors')).to.have.length 1

          @form.$el.find('[name=age]').val('18')
          @form.save()

        res.done =>
          root = @form.$el

          expect(root.find('ul.errors')).to.have.length 0
          expect(root.find('.age-div.error')).to.have.length 0

          done()

describe 'Date Field', ->
  beforeEach ->
    test.create()
    @el = $('<input type="text" class="date"/>')

  afterEach ->
    test.destroy()

  describe 'when setting a value', ->
    it 'should set a date', ->
      @el.val('')
      forms.dateField.set(@el, '1999-04-22T13:45:55Z')
      expect(@el.val()).to.equal '04/22/1999'


  describe 'when getting a value', ->
    it 'should get a date', ->
      @el.val('04/22/1999 8:45:55 AM')
      expect(forms.dateField.get(@el)).to.equal '1999-04-22T13:45:55Z'

describe 'Int Field', ->

  beforeEach ->
    test.create()

  afterEach ->
    test.destroy()

  describe 'when setting a value', ->
    it 'should set a zero when NaN', ->
      @el.val('')
      forms.intField.set(@el, NaN)
      expect(@el.val()).to.equal '0'

    it 'should set a zero when no value', ->
      @el.val('')
      forms.intField.set(@el, '')
      expect(@el.val()).to.equal '0'

    it 'should commafy the value', ->
      @el.val('')
      forms.intField.set(@el, 1234567)
      expect(@el.val()).to.equal '1,234,567'

  describe 'when getting a value', ->
    it 'should error when invalid', ->
      @el.val('THIS IS NOT VALID%&%& 122 @&%')
      expect(-> forms.intField.get(@el)).to.throw TypeError

    it 'should return a default value if provided', ->
      @el.val('THIS IS NOT VALID%&%& 122 @&%')
      expect(forms.intField.get(@el, 2)).to.equal 2

    it 'should accept a value with commas', ->
      @el.val('1,234')
      expect(forms.intField.get(@el)).to.equal 1234

describe 'Money Field', ->

  beforeEach ->
    test.create()
    @el = $('<input type="text"/>')

  afterEach ->
    test.destroy()

  describe 'when setting a value', ->
    it 'should set a proper decimal', ->
      @el.val('')
      forms.moneyField.set(@el, '123.456')
      expect(@el.val()).to.equal('123.46')

    it 'should set a zero when NaN', ->
      @el.val('')
      forms.moneyField.set(@el, NaN)
      expect(@el.val()).to.equal('0.00')

    it 'should set a zero when no value', ->
      @el.val('')
      forms.moneyField.set(@el, '')
      expect(@el.val()).to.equal('0.00')

    it 'should commafy value', ->
      @el.val('')
      forms.moneyField.set(@el, '12345678.38')
      expect(@el.val()).to.equal('12,345,678.38')

describe 'Float Field', ->

  beforeEach ->
    test.create()
    @el = $('<input type="text"/>')

  afterEach ->
    test.destroy()

  describe 'when setting a value', ->
    it 'should set a proper decimal', ->
      @el.val('')
      forms.floatField.set(@el, '123.456')
      expect(@el.val()).to.equal('123.456')

    it 'should set a zero when NaN', ->
      @el.val('')
      forms.floatField.set(@el, NaN)
      expect(@el.val()).to.equal('0')

    it 'should set a zero when no value', ->
      @el.val('')
      forms.floatField.set(@el, '')
      expect(@el.val()).to.equal('0')

describe 'Money Field', ->

  beforeEach ->
    test.create()
    @el = $('<input type="text"/>')

  afterEach ->
    test.destroy()

  describe 'when getting a value', ->
    it 'should have 2 places', ->
      @el.val('123.456')
      expect(forms.moneyField.get(@el)).to.equal '123.46'

    it 'should error when invalid', ->
      @el.val('THIS IS NOT VALID%&%& 123.42 @&%')
      expect(-> forms.moneyField.get(@el)).to.throw TypeError

    it 'should return a default value if provided', ->
      @el.val('THIS IS NOT VALID%&%& 123.42 @&%')
      expect(forms.moneyField.get(@el, 0.00)).to.equal 0.00

    it 'should ignore commas', ->
      @el.val('5,000,000')
      expect(forms.moneyField.get(@el)).to.equal '5000000.00'


describe 'Date Time Field', ->
  beforeEach ->
    test.create()
    @doc = $ """
      <p>
        <input type="text" name="start_date" class="date"/>
        <select name="start_date" class="time"></select>
      </p>
    """

    @input = @doc.find '[name=start_date]'
    @date  = '1945-09-02T13:45:55Z'

  afterEach ->
    test.destroy()

  it 'should populate the time choices on set', ->
    expect(@input.filter('.date')).to.have.val ''
    expect(@input.filter('.time')).to.have.val null

    forms.dateTimeField.set(@input, @date)
    expect(@input.filter('.date')).to.have.val '09/02/1945'
    expect(@input.filter('.time').find('option')).to.have.length 24
    expect(@input.filter('.time')).to.have.val '8:00 AM'

  it 'should populate the time choices on set with null date', ->
    forms.dateTimeField.set(@input, null)
    expect(@input.filter('.time').find('option')).to.have.length 24

  it 'should the value from a form', ->
    forms.dateTimeField.set(@input, @date)
    datetime = forms.dateTimeField.get(@input)
    expect(datetime).to.equal '1945-09-02T13:00:00Z'
