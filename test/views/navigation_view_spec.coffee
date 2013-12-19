require '../setup'
expect  = require('chai').expect

Model          = require 'models/model'
NavigationView = require 'views/navigation_view'


describe 'NavigationView', ->
  beforeEach ->
    template = ->
      """
        <ul class="primary">
          <li>
            <a href="#/reporting/" class="reporting">Reporting</a>
          </li>
          <li>
            <a href="#/planning/" class="planning">Planning</a>
          </li>
        </ul>
        <ul class="secondary reporting">
          <li>
            <a href="#/reporting/1">Reporting sub tab 1</a>
          </li>
          <li>
            <a href="#/reporting/2">Reporting sub tab 2</a>
          </li>
        </ul>
      """

    @view = new NavigationView(new Model(), template).render()
    @find = (s) => @view.$el.find(s)

  afterEach ->
    @view.remove()

  # This will error out as of d5f00da
  it 'should handle blank routes as catch-all', ->
    @view.updateSecondary('')

  it 'should highlight the first tab by default', ->
    expect(@find('.primary a.reporting').parent().hasClass('active')).to.be.true

  it 'should highlight the primary tab when a secondary tab is clicked', ->
    @find('.active').removeClass('active')
    expect(@find('.primary a.reporting').parent().hasClass('active')).to.be.false
    @view.updateSecondary("#/reporting/1")
    expect(@find('.primary a.reporting').parent().hasClass('active')).to.be.true
    expect(@find('.secondary a[href="#/reporting/1"]').parent().hasClass('active')).to.be.true

  it 'should highlight no secondary menu if the primary does not have one', ->
    @find('.active').removeClass('active')
    expect(@find('.primary a.planning').parent().hasClass('active')).to.be.false
    @view.updateSecondary("#/planning/")
    expect(@find('.primary a.planning').parent().hasClass('active')).to.be.true
    expect(@find('.secondary .active').length).to.equal 0
