require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'hpricot'

describe IssuesController do
  it_has_behavior 'ApplicationController protected methods'
end

describe IssuesController, 'GET /issues/search' do
  def do_get
    get :search, :issue => { :summary => 'foo' }
  end

  # these tests are fairly weak at the moment because I don't want to start
  # mocking the internal implementation details too much (I may already have
  # gone too far); I will add fuller specs later which test only the external
  # behaviour
  it 'should check the default_access_options' do
    mock(controller).default_access_options
    do_get
  end

  it 'calls Issue.search' do
    mock.proxy(Issue).search(anything, anything)
    do_get
  end

  it "propagates the user's sort options" do
    mock(controller).arel_sort_options { '' }
    do_get
  end

  it 'finds all applicable issues' do
    do_get
    assigns[:issues].should be_kind_of(Array)
  end
end

describe IssuesController, 'GET /issues/:id' do
  def do_get issue
    get :show, :id => issue.id
  end

  it 'should run the "find_prev_next" before filter' do
    mock(controller).find_prev_next
    do_get Issue.make!
  end
end

describe IssuesController, 'GET /issues/:id.atom' do
  render_views # so that we can test layouts as well

  def do_get issue
    get :show, :id => issue.id, :format => 'atom'
  end

  it 'should not run the "find_prev_next" before filter' do
    do_not_allow(controller).find_prev_next
    do_get Issue.make!
  end

  # make sure we don't get bitten by bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom' do
    pending unless can_validate_feeds?
    do_get Issue.make!
    response.body.should be_valid_atom
  end

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  it 'should produce entry links to HTML-formatted records' do
    issue = Issue.make!
    10.times {
      # feed has one entry for issue, and one entry for each comment
      # so to fully catch this bug need some comments on the issue
      comment = issue.comments.build :body => Sham.random
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
    @issue = Issue.make! :awaiting_moderation => false # this is the default example data anyway, but be explicit
    log_in_as_admin
  end

  def do_get
    get :edit, :id => @issue.id
  end

  it 'should require administrator privileges' do
    mock(controller).require_admin # before filter
    do_get
  end

  it 'should find the issue' do
    mock.proxy(controller).find_issue_awaiting_moderation # before filter
    do_get
  end

  it 'should be successful for issues awaiting moderation' do
    @issue = Issue.make! :awaiting_moderation => true
    do_get
    response.should be_success
  end

  it 'should be successful for issues not awaiting moderation' do
    do_get
    response.should be_success
  end

  it 'should render the edit template for issues awaiting modeartion' do
    @issue = Issue.make! :awaiting_moderation => true
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
    @issue = Issue.make
    stub(Issue).new { @issue }
  end

  def do_post
    post :create, :issue => { :pending_tags => 'foo bar baz' }
  end

  it 'should set pending tags (if posting as admin)' do
    mock(@issue).pending_tags=('foo bar baz')
    log_in_as_admin
    do_post
  end

  it 'should not set pending tags (if posting as normal or anonymous user)' do
    do_not_allow(@issue).pending_tags=
    do_post
  end
end

describe IssuesController, 'PUT /issues/:id (html format)' do
  before do
    @issue = Issue.make! :awaiting_moderation => true
    log_in_as_admin
  end

  def do_put
    put :update, :id => @issue.id, :issue => { :pending_tags => 'foo bar baz' }
  end

  it 'should require administrator privileges' do
    mock(controller).require_admin # before filter
    do_put
  end

  it 'should find the issue' do
    mock.proxy(controller).find_issue_awaiting_moderation # before filter
    do_put
  end

  it 'should update the tags' do
    mock(@issue).pending_tags=
    stub(Issue).find { @issue }
    do_put
  end

  it 'should update the issue' do
    mock(@issue).update_attributes 'pending_tags' => 'foo bar baz'
    stub(Issue).find() { @issue }
    do_put
  end

  it 'should show a notice on success' do
    stub(@issue).save { true }
    stub(Issue).find() { @issue }
    do_put
    cookie_flash[:notice].should =~ /Successfully updated/
  end

  it 'should redirect to the issue path on success for comments not awaiting moderation' do
    @issue = Issue.make!
    stub(@issue).save { true }
    stub(Issue).find() { @issue }
    do_put
    response.should redirect_to(issue_url @issue)
  end

  it 'should redirect to the list of issues awaiting moderation on success for comments that are awaiting moderation' do
    @issue.awaiting_moderation = true
    stub(@issue).save { true }
    stub(Issue).find() { @issue }
    do_put
    response.should redirect_to(admin_issues_path)
  end

  it 'should show an error on failure' do
    stub(@issue).save { false }
    stub(Issue).find() { @issue }
    do_put
    cookie_flash[:error].should =~ /Update failed/
  end

  it 'should render the edit template again on failure' do
    stub(@issue).save { false }
    stub(Issue).find() { @issue }
    do_put
    response.should render_template('edit')
  end
end

describe IssuesController, 'PUT /issues/:id (js format)' do
  before do
    @issue = Issue.make! :awaiting_moderation => true
    log_in_as_admin
  end

  def do_put button = 'ham'
    put :update, :id => @issue.id, :format => 'js', :button => button
  end

  it 'should require administrator privileges' do
    mock(controller).require_admin # before filter
    do_put
  end

  it 'should find the issue' do
    mock.proxy(controller).find_issue_awaiting_moderation
    do_put
  end

  it 'should moderate as ham when requested' do
    mock(@issue).moderate_as_ham!
    stub(Issue).find() { @issue }
    do_put
  end

  it 'should complain about unknown parameters' do
    stub(Issue).find() { @issue }
    lambda { do_put 'unknown' }.should raise_error
  end

  # TODO: stick js into an rjs template so that I can test the rest using a simple "should render_template"
end

describe IssuesController, 'regressions' do
  it 'should unset the "current_user" thread-local variable even if an exception is thrown' do
    log_in_as_admin
    record_not_found = Issue.make!.id + 1_000
    get :edit, :id => record_not_found # raises RecordNotFound
    Thread.current[:current_user].should be_nil
  end
end
