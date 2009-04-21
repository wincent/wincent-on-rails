require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_controller_spec'
require 'hpricot'

describe IssuesController do
  it_should_behave_like 'ApplicationController'
end

describe IssuesController, 'GET /issues/search' do
  def do_get
    get :search, :protocol => 'https'
  end

  # these tests are fairly weak at the moment because I don't want to start mocking the internal implementation details
  # too much (I may already have gone too far); I will add fuller specs later which test only the external behaviour
  it 'should check the default_access_options' do
    controller.should_receive(:default_access_options)
    do_get
  end

  it 'should sanitize the search parameters' do
    Issue.should_receive(:prepare_search_conditions)
    do_get
  end

  it "should propagate the user's sort options" do
    controller.should_receive(:sort_options).and_return({})
    do_get
  end

  it 'should find all applicable issues' do
    Issue.should_receive(:find)
    do_get
  end
end

describe IssuesController, 'GET /issues/:id' do
  def do_get issue
    get :show, :id => issue.id, :protocol => 'https'
  end

  it 'should run the "find_prev_next" before filter' do
    controller.should_receive(:find_prev_next)
    do_get create_issue
  end
end

describe IssuesController, 'GET /issues/:id.atom' do
  integrate_views # so that we can test layouts as well

  def do_get issue
    get :show, :id => issue.id, :format => 'atom', :protocol => 'https'
  end

  it 'should not run the "find_prev_next" before filter' do
    controller.should_not_receive(:find_prev_next)
    do_get create_issue
  end

  # make sure we don't get bitten by bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom' do
    pending unless can_validate_feeds?
    do_get create_issue
    response.body.should be_valid_atom
  end

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  it 'should produce entry links to HTML-formatted records' do
    issue = create_issue
    10.times {
      # feed has one entry for issue, and one entry for each comment
      # so to fully catch this bug need some comments on the issue
      comment = issue.comments.build :body => String.random
      comment.awaiting_moderation = false
      comment.save
    }
    do_get issue
    doc = Hpricot.XML(response.body)
    (doc/:entry).collect do |entry|
      (entry/:link).first[:href].each do |href|
        # make sure links are /issues/1234#comment_3000, not /issues/1234.atom#comment_3000
        href.should_not =~ %r{\.atom}
      end
    end
  end

  it 'should redirect to main issues feed for non-existent issues' do
    pending 'broken because redirects to issues.atom, which is not yet implemented'
  end

  it 'should redirect to main issues feed for private issues' do
    pending 'broken because redirects to issues.atom, which is not yet implemented'
  end
end

describe IssuesController, 'GET /issues/:id/edit' do
  before do
    @issue = create_issue :awaiting_moderation => false # this is the default example data anyway, but be explicit
    login_as_admin
  end

  def do_get
    get :edit, :id => @issue.id, :protocol => 'https'
  end

  it 'should require administrator privileges' do
    controller.should_receive(:require_admin) # before filter
    do_get
  end

  it 'should find the issue' do
    controller.should_receive(:find_issue_awaiting_moderation) # before filter
    do_get
  end

  it 'should be successful for issues awaiting moderation' do
    @issue = create_issue :awaiting_moderation => true
    do_get
    response.should be_success
  end

  it 'should be successful for issues not awaiting moderation' do
    do_get
    response.should be_success
  end

  it 'should render the edit template for issues awaiting modeartion' do
    @issue = create_issue :awaiting_moderation => true
    do_get
    response.should render_template('edit')
  end

  it 'should render the edit template for issues not awaiting modeartion' do
    do_get
    response.should render_template('edit')
  end
end

describe IssuesController, 'POST /issues (html format)' do
  before do
    # use a real model instead of a mock or stub here
    # otherwise I have to mock/stub _all_ of the method calls inside the method
    # which seems a bit crazy
    @issue = new_issue
    Issue.stub!(:new).and_return(@issue)
  end

  def do_post
    post :create, :issue => { :pending_tags => 'foo bar baz' }, :protocol => 'https'
  end

  it 'should set pending tags (if posting as admin)' do
    @issue.should_receive(:pending_tags=).with('foo bar baz')
    login_as_admin
    do_post
  end

  it 'should not set pending tags (if posting as normal or anonymous user)' do
    @issue.should_not_receive(:pending_tags=)
    do_post
  end
end

describe IssuesController, 'PUT /issues/:id (html format)' do
  before do
    @issue = create_issue :awaiting_moderation => false # this is the default example data anyway, but be explicit
    login_as_admin
  end

  def do_put
    put :update, :id => @issue.id, :issue => { :pending_tags => 'foo bar baz' }, :protocol => 'https'
  end

  it 'should require administrator privileges' do
    controller.should_receive(:require_admin) # before filter
    do_put
  end

  it 'should find the issue' do
    controller.should_receive(:find_issue_awaiting_moderation) # before filter
    do_put rescue nil # by mocking we prevent assignment to the @issue instance variable, so must rescue here
  end

  it 'should update the tags' do
    @issue.should_receive(:pending_tags=)
    Issue.stub!(:find).and_return(@issue)
    do_put
  end

  it 'should update the issue' do
    @issue.should_receive(:update_attributes)
    Issue.stub!(:find).and_return(@issue)
    do_put
  end

  it 'should show a notice on success' do
    @issue.stub!(:save).and_return(true)
    Issue.stub!(:find).and_return(@issue)
    do_put
    cookie_flash['notice'].should =~ /Successfully updated/
  end

  it 'should redirect to the issue path on success for comments not awaiting moderation' do
    @issue.stub!(:save).and_return(true)
    Issue.stub!(:find).and_return(@issue)
    do_put
    response.should redirect_to(issue_url(@issue))
  end

  it 'should redirect to the list of issues awaiting moderation on success for comments that are awaiting moderation' do
    @issue.awaiting_moderation = true
    @issue.stub!(:save).and_return(true)
    Issue.stub!(:find).and_return(@issue)
    do_put
    response.should redirect_to(admin_issues_url)
  end

  it 'should show an error on failure' do
    @issue.stub!(:save).and_return(false)
    Issue.stub!(:find).and_return(@issue)
    do_put
    cookie_flash['error'].should =~ /Update failed/
  end

  it 'should render the edit template again on failure' do
    @issue.stub!(:save).and_return(false)
    Issue.stub!(:find).and_return(@issue)
    do_put
    response.should render_template('edit')
  end
end

describe IssuesController, 'PUT /issues/:id (js format)' do
  before do
    @issue = create_issue :awaiting_moderation => false # this is the default example data anyway, but be explicit
    login_as_admin
  end

  def do_put button = 'ham'
    put :update, :id => @issue.id, :format => 'js', :button => button, :protocol => 'https'
  end

  it 'should require administrator privileges' do
    controller.should_receive(:require_admin) # before filter
    do_put
  end

  it 'should find the issue' do
    controller.should_receive(:find_issue_awaiting_moderation) # before filter
    do_put rescue nil # by mocking we prevent assignment to the @issue instance variable, so must rescue here
  end

  it 'should moderate as ham when requested' do
    @issue.should_receive(:moderate_as_ham!)
    Issue.stub!(:find).and_return(@issue)
    do_put
  end

  it 'should complain about unknown parameters' do
    Issue.stub!(:find).and_return(@issue)
    lambda { do_put 'unknown' }.should raise_error
  end

  # TODO: stick js into an rjs template so that I can test the rest using a simple "should render_template"
end

describe IssuesController, 'regressions' do
  it 'should unset the "current_user" thread-local variable even if an exception is thrown' do
    login_as_admin
    record_not_found = create_issue.id + 1_000
    get :edit, :id => record_not_found, :protocol => 'https' # raises RecordNotFound
    Thread.current[:current_user].should be_nil
  end
end
