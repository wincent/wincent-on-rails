require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Admin::DashboardController do
  it_should_behave_like 'ApplicationController protected methods'
end

describe Admin::DashboardController, 'show action' do
  before do
    @conditions = 'awaiting_moderation = TRUE'
    log_in_as_admin
  end

  it 'runs the "require_admin" before filter' do
    mock(controller).require_admin
    get :show
  end

  it 'gets the count of comments awaiting moderation' do
    mock(Comment).count({:conditions => @conditions}) { 100 }
    get :show
    assigns[:comment_count].should == 100
  end

  it 'gets the count of issues awaiting moderation' do
    mock(Issue).count({:conditions => @conditions}) { 200 }
    get :show
    assigns[:issue_count].should == 200
  end

  it 'gets the count of topics awaiting moderation' do
    mock(Topic).count({:conditions => @conditions}) { 300 }
    get :show
    assigns[:topic_count].should == 300
  end

  it 'renders the show template' do
    get :show
    response.should render_template('show')
  end

  it 'is successful' do
    get :show
    response.should be_success
  end
end
