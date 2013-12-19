require '../setup'
expect  = require('chai').expect

NoticeView = require 'views/notice_view'


describe 'Notice View', ->

  beforeEach ->
    @view = new NoticeView

  afterEach ->
    @view.remove()

  describe 'By default', ->
    it 'should have no text', ->
      expect(@view.$el.text()).to.be.empty

    it 'should have no class', ->
      expect(@view.$el.attr('class')).to.be.empty


  describe 'When transitioning to error', ->
    beforeEach ->
      @view.error('>Pants<')

    it 'should have the notice-view and error classes', ->
      expect(@view.$el.attr('class')).to.include 'notice-view'
      expect(@view.$el.attr('class')).to.include 'error'

      expect(@view.$el.html()).to.equal '&gt;Pants&lt;'

    it 'should remove .notice-view when resetting', ->
      @view.reset()
      expect(@view.$el.attr('class')).to.not.include 'notice-view'
