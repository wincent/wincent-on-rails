require 'spec_helper'

describe SnippetsController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#index' do
    it 'succeeds' do
      get :index
      expect(response).to be_success
    end

    it 'renders the #index template' do
      get :index
      expect(response).to render_template('index')
    end

    it 'uses a restful paginator' do
      mock.proxy(RestfulPaginator).new.with_any_args
      get :index
    end

    it 'assigns to the @paginator instance variable' do
      get :index
      expect(assigns[:paginator]).to be_kind_of(RestfulPaginator)
    end

    it 'informs the paginator of the total number of records' do
      3.times { Snippet.make! }                   # these will be counted
      2.times { Snippet.make! :public => false }  # but these will not
      get :index
      expect(assigns[:paginator].count).to eq(3)
    end

    it 'tells the paginator to use the /snippets path for link generation' do
      get :index
      expect(assigns[:paginator].path_or_url).to eq(snippets_path)
    end

    it 'configures the paginator to paginate in groups of 10' do
      get :index
      expect(assigns[:paginator].limit).to eq(10)
    end

    it 'shows the first page by default' do
      get :index
      expect(assigns[:paginator].offset).to eq(0)
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
      expect(assigns[:snippets]).to eq([snippet])
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
        expect(assigns[:snippet]).to be_kind_of(Snippet)
        expect(assigns[:snippet]).to be_new_record
      end

      it 'renders snippets/new' do
        do_request
        expect(response).to render_template('snippets/new')
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
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
            expect(assigns[:snippet]).to be_kind_of(Snippet)
            expect(assigns[:snippet]).not_to be_new_record
          end

          it 'shows a flash' do
            expect(flash[:notice]).to match(/successfully created/i)
          end

          it 'redirects to #show' do
            expect(response).to redirect_to(snippet_path(assigns[:snippet]))
          end
        end

        context 'failed creation' do
          before do
            stub.instance_of(Snippet).save { false }
            do_request
          end

          it 'assigns a new snippet instance' do
            expect(assigns[:snippet]).to be_kind_of(Snippet)
            expect(assigns[:snippet]).to be_new_record
          end

          it 'shows a flash' do
            expect(flash[:error]).to match(/failed to create/i)
          end

          it 'renders #new' do
            expect(response).to render_template('snippets/new')
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
          expect(response).to be_success
        end

        it 'assigns a new snippet instance' do
          expect(assigns[:snippet]).to be_kind_of(Snippet)
          expect(assigns[:snippet]).to be_new_record
          expect(assigns[:snippet].body).to eq('foo')
          expect(assigns[:snippet].description).to eq('bar')
          expect(assigns[:snippet].markup_type).to eq(0)
        end

        it 'renders the "snippets/_preview" partial' do
          expect(response).to render_template('snippets/_preview')
        end
      end
    end
  end

  describe '#show' do
    let (:snippet) { Snippet.make! }

    def do_request
      get :show, :id => snippet.to_param
    end

    it 'succeeds' do
      do_request
      expect(response).to be_success
    end

    it 'finds and assigns the snippet' do
      do_request
      expect(assigns[:snippet]).to eq(snippet)
    end

    context 'with no comments' do
      it 'finds and assigns no comments' do
        do_request
        expect(assigns[:comments]).to eq([])
      end
    end

    context 'with comments' do
      it 'finds and assigns published comments' do
        published = Comment.make! :commentable => snippet
        omitted   = Comment.make! :commentable => snippet, :public => false
        do_request
        expect(assigns[:comments]).to eq([published])
      end
    end

    it 'renders "snippets/show"' do
      do_request
      expect(response).to render_template('snippets/show')
    end

    it 'should page-cache the output'

    context 'non-existent snippet' do
      it 'redirects to #index' do
        get :show, :id => '1200400'
        expect(response).to redirect_to(snippets_path)
      end
    end

    context 'private snippet' do
      let (:snippet) { Snippet.make! :public => false }

      it 'redirects to #index' do
        do_request
        expect(response).to redirect_to(snippets_path)
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
        expect(response).to be_success
      end

      it 'finds and assigns the snippet instance' do
        do_request
        expect(assigns[:snippet]).to eq(snippet)
      end

      it 'renders "snippets/edit"' do
        do_request
        expect(response).to render_template('snippets/edit')
      end

      context 'non-existent snippet' do
        it 'redirects to #index' do
          get :edit, :id => '1324187'
          expect(response).to redirect_to(snippets_path)
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
        expect(assigns[:snippet]).to eq(snippet.reload)
      end

      context 'successful update' do
        it 'shows a flash' do
          do_request
          expect(flash[:notice]).to match(/successfully updated/i)
        end

        it 'redirects to #show' do
          do_request
          expect(response).to redirect_to(snippet_path(snippet))
        end

        it 'updates the instance' do
          do_request
          expect(snippet.reload.body).to eq('fancy new body')
        end
      end

      context 'failed update' do
        before do
          stub.instance_of(Snippet).update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/update failed/i)
        end

        it 'renders #edit' do
          do_request
          expect(response).to render_template('snippets/edit')
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
          Snippet.find snippet.id
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'redirects to #index' do
        do_request
        expect(response).to redirect_to(snippets_path)
      end

      it 'shows a flash' do
        do_request
        expect(flash[:notice]).to match(/successfully destroyed/i)
      end

      context 'non-existent snippet' do
        def do_request
          delete :destroy, :id => '32190987'
        end

        it 'redirects to #index' do
          do_request
          expect(response).to redirect_to(snippets_path)
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/not found/i)
        end
      end
    end
  end
end
