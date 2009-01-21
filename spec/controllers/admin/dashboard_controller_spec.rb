require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../application_controller_spec'

describe Admin::DashboardController do
  it_should_behave_like 'ApplicationController'
end

describe Admin::DashboardController, 'show action' do
  before do
    @conditions = 'awaiting_moderation = TRUE'
    login_as_admin
  end

  def do_get
    get 'show', :protocol => 'https'
  end

  it 'should run the "require_admin" before filter' do
    controller.should_receive(:require_admin)
    do_get
  end

  it 'should get the count of comments awaiting moderation' do
    Comment.should_receive(:count).with({:conditions => @conditions}).and_return(100)
    do_get
    assigns[:comment_count].should == 100
  end

  it 'should get the count of issues awaiting moderation' do
    Issue.should_receive(:count).with({:conditions => @conditions}).and_return(200)
    do_get
    assigns[:issue_count].should == 200
  end

  it 'should get the count of topics awaiting moderation' do
    Topic.should_receive(:count).with({:conditions => @conditions}).and_return(300)
    do_get
    assigns[:topic_count].should == 300
  end

  it 'should render the show template' do
    do_get
    response.should render_template('show')
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end
end
