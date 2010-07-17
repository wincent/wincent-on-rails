require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe CommentsController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end

describe CommentsController, 'GET /comments/:id/edit logged in as admin' do
  before do
    @comment = Comment.make!
    log_in_as_admin
  end

  def do_get
    get :edit, :id => @comment.id
  end

  it 'runs the "require_admin" before filter' do
    mock(controller).require_admin
    do_get
  end

  it 'finds the comment' do
    mock(Comment).find(@comment.id)
    do_get
  end

  it 'is successful' do
    do_get
    response.should be_success
  end

  it 'renders the edit template' do
    do_get
    response.should render_template('edit')
  end
end

describe CommentsController, 'GET /comments/:id/edit logged in as normal user' do
  before do
    @comment = Comment.make!
  end

  # strictly speaking this is re-testing the require_admin method
  # but the effort is minimal, so it doesn't hurt to err on the safe side
  it 'denies access to the "edit" action' do
    log_in
    get :edit, :id => @comment.id
    response.should redirect_to(login_path)
    cookie_flash['notice'].should =~ /requires administrator privileges/
  end
end

describe CommentsController, 'GET /comments/:id/edit as an anonymous visitor' do
  before do
    @comment = Comment.make!
  end

  # strictly speaking this is re-testing the require_admin method
  # but the effort is minimal, so it doesn't hurt to err on the safe side
  it 'denies access to the "edit" action' do
    get :edit, :id => @comment.id
    response.should redirect_to(login_path)
    cookie_flash['notice'].should =~ /requires administrator privileges/
  end
end

describe CommentsController, 'PUT /comments/:id logged in as admin' do
  before do
    @comment = Comment.make!
    log_in_as_admin
  end

  def do_put
    put :update, :id => @comment.id, :comment => { :body => 'foo' }
  end

  it 'runs the "require_admin" before filter' do
    mock(controller).require_admin
    do_put
  end

  it 'finds the comment and assign it to an instance variable' do
    do_put
    assigns[:comment].should == @comment
  end

  it 'updates the comment' do
    mock(@comment).update_attributes 'body' => 'foo'
    stub(Comment).find() { @comment }
    do_put
  end

  it 'shows a notice on success' do
    stub(@comment).save { true }
    stub(Comment).find() { @comment }
    do_put
    cookie_flash['notice'].should =~ /Successfully updated/
  end

  it 'redirects to the comment path on success for comments not awaiting moderation' do
    stub(@comment).save { true }
    stub(Comment).find() { @comment }
    do_put
    response.should redirect_to(controller.send(:nested_comment_path, @comment))
  end

  it 'redirects to the list of comments awaiting moderation on success for comments that are awaiting moderation' do
    @comment.awaiting_moderation = true
    stub(@comment).save { true }
    stub(Comment).find() { @comment }
    do_put
    response.should redirect_to(comments_path)
  end

  it 'shows an error on failure' do
    stub(@comment).save { false }
    stub(Comment).find() { @comment }
    do_put
    cookie_flash['error'].should =~ /Update failed/
  end

  it 'renders the edit template again on failure' do
    stub(@comment).save { false }
    stub(Comment).find() { @comment }
    do_put
    response.should render_template('edit')
  end
end

# Testing the CommentsController (use of ActionController::ForbiddenError) and
# AppController (use of "forbidden" method) here, but using the
# TweetsController as a concrete example seeing as that's where we first saw
# this kind of request (see commit 2a897ba).
describe CommentsController, 'GET /twitter/:id/comments/new' do
  describe 'when commenting not allowed' do
    before do
      tweet = Tweet.make! :accepts_comments => false
      get :new, :tweet_id => tweet.id
    end

    it 'is not successful' do
      response.should_not be_success
    end

    it 'returns a 403 status' do
      response.status.should == 403
    end
  end
end
