require 'spec_helper'

describe SnippetsController do
  it_has_behavior 'ApplicationController protected methods'

  describe '#index' do
    describe 'HTML format' do
      it 'succeeds' do
        get :index
        response.should be_success
      end

      it 'renders the #index template' do
        get :index
        response.should render_template('index')
      end

      it 'uses a restful paginator' do
        mock.proxy(RestfulPaginator).new.with_any_args
        get :index
      end

      it 'assigns to the @paginator instance variable' do
        get :index
        assigns[:paginator].should be_kind_of(RestfulPaginator)
      end

      it 'informs the paginator of the total number of records' do
        3.times { Snippet.make! }                   # these will be counted
        2.times { Snippet.make! :public => false }  # but these will not
        get :index
        assigns[:paginator].count.should == 3
      end

      it 'tells the paginator to use the /snippets path for link generation' do
        get :index
        assigns[:paginator].path_or_url.should == snippets_path
      end

      it 'configures the paginator to paginate in groups of 10' do
        get :index
        assigns[:paginator].limit.should == 10
      end

      it 'shows the first page by default' do
        get :index
        assigns[:paginator].offset.should == 0
      end

      it 'finds recent snippets' do
        mock.proxy(Snippet).recent
        get :index
      end

      it 'uses the offset supplied by the paginator' do
        stub(Snippet).published.stub!.count { 100 }
        stub(Snippet).recent.mock!.offset(10)
        get :index, :page => '2'
      end

      it 'assigns found snippets' do
        snippet = Snippet.make!
        get :index
        assigns[:snippets].should == [snippet]
      end

      it 'should page-cache the output'
      # turning on page caching contaminates the production "public" folder
      # but without page caching turned on, it doesn't even set up the filter
    end

    describe  'Atom fortmat' do
      render_views # so that we can test layouts as well

      def do_get
        get :index, :format => 'atom'
      end

      it 'succeeds' do
        do_get
        response.should be_success
      end

      it 'renders the #index template' do
        do_get
        response.should render_template('index')
      end

      it 'finds recent snippets' do
        mock.proxy(Snippet).recent
        do_get
      end

      it 'assigns to the @snippets instance variable' do
        snippet = Snippet.make!
        do_get
        assigns[:snippets].should == [snippet]
      end

      it 'page-caches the output'

      context 'no snippets' do
        it 'produces valid Atom' do
          pending unless can_validate_feeds?
          do_get
          response.body.should be_valid_atom
        end
      end

      context 'multiple snippets' do
        before do
          10.times { Snippet.make! }
        end

        it 'produces valid Atom' do
          pending unless can_validate_feeds?
          do_get
          response.body.should be_valid_atom
        end
      end
    end
  end

  describe '#new' do
    it_has_behavior 'require_admin'

    def do_request
      get :new
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'assigns a new snippet instance' do
        do_request
        assigns[:snippet].should be_kind_of(Snippet)
        assigns[:snippet].should be_new_record
      end

      it 'renders snippets/new' do
        do_request
        response.should render_template('snippets/new')
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end
    end
  end

  describe '#create' do
    describe 'HTML format' do
      it_has_behavior 'require_admin'

      before do
        @params = { 'snippet' => Snippet.valid_attributes.stringify_keys }
      end

      def do_request
        post :create, @params
      end

      context 'admin user' do
        before do
          log_in_as_admin
        end

        context 'successful creation' do
          before do
            do_request
          end

          it 'creates a new snippet record' do
            assigns[:snippet].should be_kind_of(Snippet)
            assigns[:snippet].should_not be_new_record
          end

          it 'shows a flash' do
            cookie_flash[:notice].should =~ /successfully created/i
          end

          it 'redirects to #show' do
            response.should redirect_to(snippet_path(assigns[:snippet]))
          end
        end

        context 'failed creation' do
          before do
            stub.instance_of(Snippet).save { false }
            do_request
          end

          it 'assigns a new snippet instance' do
            assigns[:snippet].should be_kind_of(Snippet)
            assigns[:snippet].should be_new_record
          end

          it 'shows a flash' do
            cookie_flash[:error].should =~ /failed to create/i
          end

          it 'renders #new' do
            response.should render_template('snippets/new')
          end
        end
      end
    end

    describe 'via XHR' do
      it_has_behavior 'require_admin (non-HTML)'

      before do
        @params = {
          'body' => 'foo', 'description' => 'bar', 'markup_type' => '0'
        }
      end

      def do_request
        request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
        post :create, @params.merge({ :format => 'js' })
      end

      context 'admin user' do
        before do
          log_in_as_admin
          do_request
        end

        it 'succeeds' do
          response.should be_success
        end

        it 'assigns a new snippet instance' do
          assigns[:snippet].should be_kind_of(Snippet)
          assigns[:snippet].should be_new_record
          assigns[:snippet].body.should == 'foo'
          assigns[:snippet].description.should == 'bar'
          assigns[:snippet].markup_type.should == 0
        end

        it 'renders the "snippets/_preview" partial' do
          response.should render_template('snippets/_preview')
        end
      end
    end
  end

  describe '#show' do
    describe 'HTML format' do
      let (:snippet) { Snippet.make! }

      def do_request
        get :show, :id => snippet.to_param
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end

      it 'finds and assigns the snippet' do
        do_request
        assigns[:snippet].should == snippet
      end

      context 'with no comments' do
        it 'finds and assigns no comments' do
          do_request
          assigns[:comments].should == []
        end
      end

      context 'with comments' do
        it 'finds and assigns published comments' do
          published = Comment.make! :commentable => snippet
          omitted   = Comment.make! :commentable => snippet, :public => false
          do_request
          assigns[:comments].should == [published]
        end
      end

      it 'renders "snippets/show"' do
        do_request
        response.should render_template('snippets/show')
      end

      it 'should page-cache the output'

      context 'non-existent snippet' do
        it 'redirects to #index' do
          get :show, :id => '1200400'
          response.should redirect_to(snippets_path)
        end
      end

      context 'private snippet' do
        let (:snippet) { Snippet.make! :public => false }

        it 'redirects to #index' do
          do_request
          response.should redirect_to(snippets_path)
        end
      end
    end

    describe 'Atom format' do
      render_views # so that we can test layouts as well

      let(:snippet) { Snippet.make! }

      def do_request
        get :show, :id => snippet.to_param, :format => 'atom'
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end

      it 'finds and assigns the snippet' do
        do_request
        assigns[:snippet].should == snippet
      end

      context 'no comments' do
        it 'finds and assigns no comments' do
          do_request
          assigns[:comments].should == []
        end

        it 'produces valid Atom' do
          pending unless can_validate_feeds?
          do_request
          response.body.should be_valid_atom
        end
      end

      context 'multiple comments' do
        before do
          @comments = []
          5.times { @comments << Comment.make!(:commentable => snippet) }
        end

        it 'finds and assigns published comments' do
          Comment.make! :commentable => snippet, :public => false # omitted
          do_request
          assigns[:comments].should =~ @comments
        end

        it 'produces valid Atom' do
          pending unless can_validate_feeds?
          do_request
          response.body.should be_valid_atom
        end
      end
    end
  end

  describe '#edit' do
    it_has_behavior 'require_admin'

    let (:snippet) { Snippet.make! }

    def do_request
      get :edit, :id => snippet.to_param
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end

      it 'finds and assigns the snippet instance' do
        do_request
        assigns[:snippet].should == snippet
      end

      it 'renders "snippets/edit"' do
        do_request
        response.should render_template('snippets/edit')
      end

      context 'non-existent snippet' do
        it 'redirects to #index' do
          get :edit, :id => '1324187'
          response.should redirect_to(snippets_path)
        end
      end
    end
  end

  describe '#update' do
    it_has_behavior 'require_admin'

    let (:snippet) { Snippet.make! }

    before do
      @params = {
        :id => snippet.to_param,
        :snippet => { 'body' => 'fancy new body' }
      }
    end

    def do_request
      put :update, @params
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the snippet' do
        do_request
        assigns[:snippet].should == snippet.reload
      end

      context 'successful update' do
        it 'shows a flash' do
          do_request
          cookie_flash[:notice].should =~ /successfully updated/i
        end

        it 'redirects to #show' do
          do_request
          response.should redirect_to(snippet_path(snippet))
        end

        it 'updates the instance' do
          do_request
          snippet.reload.body.should == 'fancy new body'
        end

        it 'triggers the cache sweeper' do
          mock(SnippetSweeper.instance).after_save(snippet)
          do_request
        end
      end

      context 'failed update' do
        before do
          stub.instance_of(Snippet).update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          cookie_flash[:error].should =~ /update failed/i
        end

        it 'renders #edit' do
          do_request
          response.should render_template('snippets/edit')
        end
      end
    end
  end

  describe '#destroy' do
    it_has_behavior 'require_admin'

    let (:snippet) { Snippet.make! }

    def do_request
      delete :destroy, :id => snippet.to_param
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'destroys the snippet' do
        do_request
        expect do
          Tweet.find snippet.id
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'redirects to #index' do
        do_request
        response.should redirect_to(snippets_path)
      end

      it 'triggers the cache sweeper' do
        mock(SnippetSweeper.instance).after_destroy(snippet)
        do_request
      end

      it 'shows a flash' do
        do_request
        cookie_flash[:notice].should =~ /successfully destroyed/i
      end

      context 'non-existent snippet' do
        def do_request
          delete :destroy, :id => '32190987'
        end

        it 'redirects to #index' do
          do_request
          response.should redirect_to(snippets_path)
        end

        it 'shows a flash' do
          do_request
          flash[:error].should =~ /not found/i

          pending "cookie_flash broken"
          # this is how I'd like to do it (see ArticlesController specs for
          # more detailed notes on this breakage):
          cookie_flash[:error].should =~ /not found/i
        end
      end
    end
  end
end
