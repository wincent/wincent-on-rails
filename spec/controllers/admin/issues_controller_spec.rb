require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../application_controller_spec'

describe Admin::IssuesController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end

describe Admin::IssuesController, 'index action' do
  before do
    login_as_admin
  end

  def do_get
    get 'index', :protocol => 'https'
  end

  it 'should run the "require_admin" before_filter' do
    controller.should_receive(:require_admin)
    do_get
  end

  it 'should render the index template' do
    do_get
    response.should render_template('index')
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  # was a bug: https://wincent.com/issues/1100
  it 'should paginate in groups of 20' do
    paginator = Paginator.new({}, 100, 'foo', 20)
    Paginator.should_receive(:new).with(anything(), anything(), anything(), 20).and_return(paginator)
    Issue.should_receive(:find).with(anything(), hash_including(:limit => paginator.limit))
    do_get
  end
end
