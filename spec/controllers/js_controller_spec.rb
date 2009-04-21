require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.dirname(__FILE__) + '/application_controller_spec'

describe JsController do
 it_should_behave_like 'ApplicationController'
end

describe JsController, 'GET /js/:delegated' do
  def do_get
    delegated = [@delegating_controller, @delegated_action]
    delegated.unshift @namespace if @namespace
    get :show, :protocol => 'https', :delegated => delegated.join('/')
  end

  before do
    @namespace = nil
    @delegating_controller = 'issues'
    @delegated_action = 'edit'
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should render the "js/issues/show.js.erb" template' do
    do_get
    response.should render_template('js/issues/edit.js.erb')
  end

  it 'should render templates in the admin namespace' do
    @namespace = 'admin'
    do_get
    response.should render_template('js/admin/issues/edit.js.erb')
  end

  it 'should not use a layout' do
    do_get
    controller.active_layout.should be_nil
  end

  it 'should not page-cache the output' do
    controller.should_not_receive(:cache_page)
    do_get
  end

  it 'should complain if delegating namespace parameter is invalidly formatted' do
    @namespace = '99999'
    lambda { do_get }.should raise_error(ActionController::RoutingError)
  end

  it 'should complain if delegating controller parameter is invalidly formatted' do
    @delegating_controller = '99999'
    lambda { do_get }.should raise_error(ActionController::RoutingError)
  end

  it 'should complain if delegated action parameter is invalidly formatted' do
    @delegated_action = 'foo-bar'
    lambda { do_get }.should raise_error(ActionController::RoutingError)
  end

  it 'should complain if both controller and action not supplied' do
    lambda {
      get :show, :protocol => 'https', :delegated => 'mycontroller'
    }.should raise_error(ActionController::RoutingError)
    lambda {
      get :show, :protocol => 'https', :delegated => 'mycontroller/'
    }.should raise_error(ActionController::RoutingError)
  end

  it 'should complain about maliciously formatted parameters (..)' do
    lambda {
      get :show, :protocol => 'https', :delegated => '../../../../etc/passwd'
    }.should raise_error(ActionController::RoutingError)
  end
end
