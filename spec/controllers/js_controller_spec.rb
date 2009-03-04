require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.dirname(__FILE__) + '/application_controller_spec'

describe JsController do
 it_should_behave_like 'ApplicationController'
end

describe JsController, 'GET /js/:delegating_controller/:delegated_action' do
  def do_get
    get :show, :protocol => 'https', :delegating_controller => @delegating_controller, :delegated_action => @delegated_action
  end

  before do
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

  it 'should not use a layout' do
    do_get
    controller.active_layout.should be_nil
  end

  it 'should not page-cache the output' do
    controller.should_not_receive(:cache_page)
    do_get
  end

  it 'should complain if delegating controller parameter is invalidly formatted' do
    @delegating_controller = '99999'
    lambda { do_get }.should raise_error(ArgumentError)
  end

  it 'should complain if delegated action parameter is invalidly formatted' do
    @delegated_action = '_____'
    lambda { do_get }.should raise_error(ArgumentError)
  end
end
