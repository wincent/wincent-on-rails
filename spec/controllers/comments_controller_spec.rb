require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_spec'

describe CommentsController do
  it_should_behave_like 'ApplicationController'
end

describe CommentsController, 'GET /comments/:id/edit logged in as admin' do
  before do
    @comment = create_comment
    login_as_admin
  end

  it 'should run the "require_admin" before filter' do
    controller.should_receive(:require_admin)
    get :edit, :id => @comment.id
  end

  it 'should find the comment' do
    Comment.should_receive(:find).with(@comment.id.to_s) # form params come through as strings
    get :edit, :id => @comment.id
  end

  it 'should be successful' do
    get :edit, :id => @comment.id
    response.should be_success
  end

  it 'should render the edit template' do
    get :edit, :id => @comment.id
    response.should render_template('edit')
  end
end

describe CommentsController, 'GET /comments/:id/edit logged in as normal user' do
  before do
    @comment = create_comment
  end

  # strictly speaking this is re-testing the require_admin method
  # but the effort is minimal, so it doesn't hurt to err on the safe side
  it 'should deny access to the "edit" action' do
    login_as_normal_user
    get :edit, :id => @comment.id
    response.should redirect_to(login_path)
    flash[:notice].should =~ /requires administrator privileges/
  end
end

describe CommentsController, 'GET /comments/:id/edit as an anonymous visitor' do
  before do
    @comment = create_comment
  end

  # strictly speaking this is re-testing the require_admin method
  # but the effort is minimal, so it doesn't hurt to err on the safe side
  it 'should deny access to the "edit" action' do
    get :edit, :id => @comment.id
    response.should redirect_to(login_path)
    flash[:notice].should =~ /requires administrator privileges/
  end
end
