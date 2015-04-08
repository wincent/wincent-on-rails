require 'spec_helper'

describe ArticlesController do
  describe '#index' do
    it 'uses a RESTful paginator' do
      mock.proxy(RestfulPaginator).new.with_any_args
      get :index
    end

    it 'assigns the paginator' do
      stub.proxy(RestfulPaginator).new.with_any_args { |double| @paginator = double }
      get :index
      expect(assigns[:paginator]).to eq(@paginator)
    end

    it 'finds recent articles' do
      mock.proxy(Article).recent.with_any_args
      get :index
    end

    it 'assigns found articles' do
      articles = [Article.make!]
      get :index
      expect(assigns[:articles]).to eq(articles)
    end

    it 'finds top tags' do
      mock(Article).find_top_tags
      get :index
    end

    it 'assigns found tags' do
      tags = [Tag.make!]
      stub(Article).find_top_tags { tags }
      get :index
      expect(assigns[:tags]).to eq(tags)
    end

    it 'succeeds' do
      get :index
      expect(response).to be_success
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe '#show' do
    context 'public article' do
      before do
        @article = Article.make! :title => 'foo'
        @comments = Array.new(5) { Comment.make! :commentable => @article }
      end

      it 'assigns the article' do
        get :show, :id => 'foo'
        expect(assigns[:article]).to eq(@article)
      end

      it 'assigns existing comments' do
        get :show, :id => 'foo'
        expect(assigns[:comments].to_a).to match_array(@comments)
      end

      context 'comments allowed' do
        it 'assigns a new comment' do
          get :show, :id => 'foo'
          expect(assigns[:comment]).to be_kind_of(Comment)
          expect(assigns[:comment].commentable).to eq(@article)
          expect(assigns[:comment]).to be_new_record
        end
      end

      context 'comments not allowed' do
        it 'does not assign a new comment' do
          Article.make! :title => 'baz', :accepts_comments => false
          get :show, :id => 'baz'
          expect(assigns[:comment]).to be_nil
        end
      end

      it 'succeeds' do
        get :show, :id => 'foo'
        expect(response).to be_success
      end

      it 'renders the show template' do
        get :show, :id => 'foo'
        expect(response).to render_template('show')
      end

      context 'redirecting from another article' do
        before do
          @redirected_from = Article.make! :title => 'bar'
          session[:redirected_from] = 'bar'
          get :show, :id => 'foo'
        end

        it 'assigns redirection info' do
          expect(assigns[:redirected_from]).to eq(@redirected_from)
        end

        it 'clears redirection info' do
          expect(session[:redirected_from]).to be_nil
          expect(session[:redirection_count]).to eq(0)
        end
      end

      context 'redirecting to an external site' do
        before do
          @article = Article.make! \
            :title    => 'bar',
            :redirect => 'http://example.com/bar',
            :body     => ''
        end

        it 'redirects' do
          get :show, :id => 'bar'
          expect(response).to redirect_to('http://example.com/bar')
        end
      end

      context 'redirecting to another article' do
        before do
          @article = Article.make! \
            :title => 'bar',
            :redirect => '[[foo]]',
            :body => ''
        end

        it 'increments the redirection count' do
          session[:redirection_count] = 2
          get :show, :id => 'bar'
          expect(session[:redirection_count]).to eq(3)
        end

        it 'records the originating article' do
          get :show, :id => 'bar'
          expect(session[:redirected_from]).to eq('bar')
        end

        it 'redirects' do
          get :show, :id => 'bar'
          expect(response).to redirect_to('/wiki/foo')
        end

        describe 'detecting a redirection loop' do
          before do
            session[:redirection_count] = 6
          end

          it 'clears the direction info' do
            get :show, :id => 'bar'
            expect(session[:redirected_from]).to be_nil
            expect(session[:redirection_count]).to eq(0)
          end

          it 'shows a flash' do
            get :show, :id => 'bar'
            expect(flash[:error]).to match(/too many redirections/i)
          end

          it 'redirects to #index' do
            get :show, :id => 'bar'
            expect(response).to redirect_to('/wiki')
          end
        end
      end
    end

    context 'private article' do
      before do
        @article = Article.make! :title => 'bar', :public => false
      end

      context 'as a normal user' do
        it 'redirects to /wiki' do
          get :show, :id => 'bar'
          expect(response).to redirect_to('/wiki')
        end

        it 'shows a flash' do
          get :show, :id => 'bar'
          expect(flash[:error]).to match(/forbidden/)
        end
      end

      context 'as an admin user' do
        before do
          log_in_as_admin
        end

        it 'succeeds' do
          get :show, :id => 'bar'
          expect(response).to be_success
        end
      end
    end

    context 'non-existent article' do
      context 'as a normal user' do
        it 'redirects to /wiki' do
          get :show, :id => 'moot'
          expect(response).to redirect_to('/wiki')
        end

        it 'shows a flash' do
          get :show, :id => 'moot'
          expect(flash[:error]).to match(/not found/)
        end
      end

      context 'as an admin user' do
        before { log_in_as_admin }

        it 'redirects to /wiki/new' do
          get :show, :id => 'moot'
          expect(response).to redirect_to('/wiki/new')
        end

        it 'shows a flash' do
          get :show, :id => 'moot'
          expect(flash[:notice]).to match(/article not found: create it\?/)
        end
      end
    end

    context 'redirect article' do
      before do
        @article = Article.make! :title => 'baz', :redirect => '[[foo]]', :body => ''
      end
    end

    describe 'regressions' do
      it 'handles HTTPS URLs in the url_or_path_for_redirect method' do
        # previously only handled HTTP URLs
        title = Sham.random
        target = 'https://example.com/'
        Article.make! :title => title, :redirect => target, :body => ''
        get :show, :id => title
        expect(response).to redirect_to(target)
      end
    end
  end

  describe '#new' do
    context 'admin access' do
      before do
        log_in_as_admin
      end

      it 'assigns a new article' do
        get :new
        expect(assigns[:article]).to be_kind_of(Article)
        expect(assigns[:article]).to be_new_record
      end

      it 'takes params from the session' do
        session[:new_article_params] = { :title => 'foo' }
        get :new
        expect(assigns[:article].title).to eq('foo')
      end

      it 'clears the session params' do
        session[:new_article_params] = { :title => 'foo' }
        get :new
        expect(session[:new_article_params]).to be_nil
      end
    end

    context 'non-admin access' do
      it 'redirects to the login page' do
        get :new
        expect(response).to redirect_to('/login')
      end
    end
  end

  describe '#create' do
    context 'admin access' do
      before do
        log_in_as_admin
      end

      context 'AJAX request' do
        it 'assigns a new article' do
          xhr :post, :create, :title => 'foo', :body => 'bar'
          expect(assigns[:article]).to be_kind_of(Article)
          expect(assigns[:article].title).to eq('foo')
          expect(assigns[:article].body).to eq('bar')
          expect(assigns[:article]).to be_new_record
        end

        it 'renders the preview partial' do
          xhr :post, :create, :title => 'foo', :body => 'bar'
          expect(response).to render_template(:partial => '_preview')
        end
      end

      context 'HTML format' do
        it 'creates a new article' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          article = Article.last
          expect(article.title).to eq('foo')
          expect(article.body).to eq('bar')
        end

        it 'assigns the new article' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          expect(assigns[:article]).to eq(Article.last)
        end

        it 'redirects to the article' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          article = Article.last
          expect(response).to redirect_to(article_path(article))
        end

        it 'shows a flash' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          expect(flash[:notice]).to match(/created new article/)
        end

        context 'article with invalid params' do
          before do
            post :create, :article => { :title => 'foo' }
          end

          it 'assigns the article' do
            expect(assigns[:article]).to be_kind_of(Article)
            expect(assigns[:article].title).to eq('foo')
            expect(assigns[:article]).to be_new_record
          end

          it 'shows an error flash' do
            expect(flash[:error]).to match(/failed to create/i)
          end

          it 'renders the #new template' do
            expect(response).to render_template('new')
          end
        end
      end
    end

    context 'non-admin access' do
      it 'redirects to the login page' do
        post :create, :article => { :title => 'foo', :body => 'bar' }
        expect(response).to redirect_to('/login')
      end
    end
  end

  describe '#edit' do
    context 'admin access' do
      before do
        @article = Article.make! :title => 'foo'
        log_in_as_admin
      end

      it 'assigns the article' do
        get :edit, :id => 'foo'
        expect(assigns[:article]).to eq(@article)
      end

      it 'renders the #edit template' do
        get :edit, :id => 'foo'
        expect(response).to render_template('edit')
      end

      context 'non-existent article' do
        it 'redirects to /wiki/new' do
          get :edit, :id => 'moot'
          expect(response).to redirect_to('/wiki/new')
        end

        it 'shows a flash' do
          get :edit, :id => 'moot'
          expect(flash[:notice]).to match(/article not found: create it\?/)
        end
      end
    end

    context 'non-admin access' do
      it 'redirects to the login page' do
        get :edit, :id => 'unimportant'
        expect(response).to redirect_to('/login')
      end
    end
  end

  describe '#update' do
    before do
      @article = Article.make! :title => 'foo'
      @params = { :id => 'foo', :article => { :body => 'bar' } }
    end

    context 'as a normal user' do
      it 'redirects to /login' do
        put :update, @params
        expect(response).to redirect_to('/login')
      end

      it 'shows a flash' do
        put :update, @params
        expect(flash[:notice]).to match(/requires administrator privileges/)
      end
    end

    context 'as an admin user' do
      before do
        log_in_as_admin
      end

      it 'updates the article' do
        put :update, @params
        expect(Article.find_by_title!('foo').body).to eq('bar')
      end

      it 'redirects to #show' do
        put :update, @params
        expect(response).to redirect_to('/wiki/foo')
      end

      it 'shows a flash' do
        put :update, @params
        expect(flash[:notice]).to match(/successfully updated/i)
      end

      context 'with invalid attributes' do
        before do
          @params = {
            :id => 'foo',
            :article => { :redirect => '--- invalid ---' }
          }
        end

        it 'shows an error flash' do
          put :update, @params
          expect(flash[:error]).to match(/update failed/i)
        end

        it 'renders #edit' do
          put :update, @params
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
