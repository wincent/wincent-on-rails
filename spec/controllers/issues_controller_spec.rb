require 'spec_helper'

describe IssuesController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#search' do
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
      mock(controller).sort_options { '' }
      do_get
    end

    it 'finds all applicable issues' do
      do_get
      assigns[:issues].should be_kind_of(Array)
    end
  end

  describe '#show' do
    def do_get issue
      get :show, :id => issue.id
    end

    it 'should run the "find_prev_next" before filter' do
      mock(controller).find_prev_next
      do_get Issue.make!
    end
  end

  describe '#edit' do
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

  describe '#create (html format)' do
    def do_post
      post :create, :issue => {
        :pending_tags => 'foo bar baz',
        :summary      => 'necessary for validation...',
      }
    end

    context 'admin user' do
      it 'sets tags' do
        log_in_as_admin
        do_post
        assigns(:issue).tag_names.should =~ %w[foo bar baz]
      end
    end

    context 'anonymous user' do
      it 'does not set tags' do
        expect do
          do_post
        end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      end
    end
  end

  describe '#update (html format)' do
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

    it 'updates the issue' do
      mock(@issue).update_attributes({'pending_tags' => 'foo bar baz'},
                                     {:as => :admin})
      stub(Issue).find { @issue }
      do_put
    end

    it 'should show a notice on success' do
      stub(@issue).save { true }
      stub(Issue).find { @issue }
      do_put
      flash[:notice].should =~ /Successfully updated/
    end

    it 'should redirect to the issue path on success for comments not awaiting moderation' do
      @issue = Issue.make!
      stub(@issue).save { true }
      stub(Issue).find { @issue }
      do_put
      response.should redirect_to(issue_url @issue)
    end

    it 'should redirect to the list of issues awaiting moderation on success for comments that are awaiting moderation' do
      @issue.awaiting_moderation = true
      stub(@issue).save { true }
      stub(Issue).find { @issue }
      do_put
      response.should redirect_to(admin_issues_path)
    end

    it 'should show an error on failure' do
      stub(@issue).save { false }
      stub(Issue).find { @issue }
      do_put
      flash[:error].should =~ /Update failed/
    end

    it 'should render the edit template again on failure' do
      stub(@issue).save { false }
      stub(Issue).find { @issue }
      do_put
      response.should render_template('edit')
    end
  end

  describe '#update (js format)' do
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

    # TODO: stick js into an rjs template so that I can test the rest using a simple "should render_template"
  end

  describe 'regressions' do
    it 'unsets the "current_user" thread-local variable even if an exception is thrown' do
      log_in_as_admin
      record_not_found = Issue.make!.id + 1_000
      get :edit, :id => record_not_found # raises RecordNotFound
      Thread.current[:current_user].should be_nil
    end
  end
end
