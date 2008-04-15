require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../application_spec'

describe Admin::DashboardController do
  it_should_behave_like 'ApplicationController'
end

describe Admin::DashboardController, 'show action' do
  before do
    @conditions = 'awaiting_moderation = TRUE'
    login_as_admin
  end

  it 'should run the "require_admin" before filter' do
    controller.should_receive(:require_admin)
    get 'show'
  end

  it 'should get the count of comments awaiting moderation' do
    Comment.should_receive(:count).with({:conditions => @conditions}).and_return(100)
    get 'show'
    assigns[:comment_count].should == 100
  end

  it 'should get the count of issues awaiting moderation' do
    Issue.should_receive(:count).with({:conditions => @conditions}).and_return(200)
    get 'show'
    assigns[:issue_count].should == 200
  end

  it 'should get the count of topics awaiting moderation' do
    Topic.should_receive(:count).with({:conditions => @conditions}).and_return(300)
    get 'show'
    assigns[:topic_count].should == 300
  end

  it 'should render the show template' do
    get 'show'
    response.should render_template('show')
  end

  it 'should be successful' do
    get 'show'
    response.should be_success
  end
end
