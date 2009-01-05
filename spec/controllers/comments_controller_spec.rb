require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_controller_spec'

describe CommentsController do
  it_should_behave_like 'ApplicationController'
end

describe CommentsController, 'GET /comments/:id/edit logged in as admin' do
  before do
    @comment = create_comment
    login_as_admin
  end

  def do_get
    get :edit, :id => @comment.id
  end

  it 'should run the "require_admin" before filter' do
    controller.should_receive(:require_admin)
    do_get
  end

  it 'should find the comment' do
    Comment.should_receive(:find).with(@comment.id.to_s) # form params come through as strings
    do_get
  end

  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should render the edit template' do
    do_get
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

describe CommentsController, 'PUT /comments/:id logged in as admin' do
  before do
    @comment = create_comment
    login_as_admin
  end

  def do_put
    put :update, :id => @comment.id
  end

  it 'should run the "require_admin" before filter' do
    controller.should_receive(:require_admin)
    do_put
  end

  it 'should find the comment' do
    Comment.should_receive(:find).with(@comment.id.to_s).and_return(@comment) # form params come through as strings
    do_put
  end

  it 'should update the comment' do
    @comment.should_receive(:update_attributes)
    Comment.stub!(:find).and_return(@comment)
    do_put
  end

  it 'should show a notice on success' do
    @comment.stub!(:save).and_return(true)
    Comment.stub!(:find).and_return(@comment)
    do_put
    flash[:notice].should =~ /Successfully updated/
  end

  it 'should redirect to the comment path on success for comments not awaiting moderation' do
    @comment.stub!(:save).and_return(true)
    Comment.stub!(:find).and_return(@comment)
    do_put
    response.should redirect_to(controller.send(:nested_comment_path, @comment))
  end

  it 'should redirect to the list of comments awaiting moderation on success for comments that are awaiting moderation' do
    @comment.awaiting_moderation = true
    @comment.stub!(:save).and_return(true)
    Comment.stub!(:find).and_return(@comment)
    do_put
    response.should redirect_to(comments_path)
  end

  it 'should show an error on failure' do
    @comment.stub!(:save).and_return(false)
    Comment.stub!(:find).and_return(@comment)
    do_put
    flash[:error].should =~ /Update failed/
  end

  it 'should render the edit template again on failure' do
    @comment.stub!(:save).and_return(false)
    Comment.stub!(:find).and_return(@comment)
    do_put
    response.should render_template('edit')
  end
end
