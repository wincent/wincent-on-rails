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
      assigns[:paginator].should == @paginator
    end

    it 'finds recent articles' do
      mock.proxy(Article).recent.with_any_args
      get :index
    end

    it 'assigns found articles' do
      articles = [Article.make!]
      get :index
      assigns[:articles].should == articles
    end

    it 'finds top tags' do
      mock(Article).find_top_tags
      get :index
    end

    it 'assigns found tags' do
      tags = [Tag.make!]
      stub(Article).find_top_tags { tags }
      get :index
      assigns[:tags].should == tags
    end

    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'renders the index template' do
      get :index
      response.should render_template('index')
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
        assigns[:article].should == @article
      end

      it 'assigns existing comments' do
        get :show, :id => 'foo'
        assigns[:comments].to_a.should =~ @comments
      end

      context 'comments allowed' do
        it 'assigns a new comment' do
          get :show, :id => 'foo'
          assigns[:comment].should be_kind_of(Comment)
          assigns[:comment].commentable.should == @article
          assigns[:comment].should be_new_record
        end
      end

      context 'comments not allowed' do
        it 'does not assign a new comment' do
          Article.make! :title => 'baz', :accepts_comments => false
          get :show, :id => 'baz'
          assigns[:comment].should be_nil
        end
      end

      it 'succeeds' do
        get :show, :id => 'foo'
        response.should be_success
      end

      it 'renders the show template' do
        get :show, :id => 'foo'
        response.should render_template('show')
      end

      context 'redirecting from another article' do
        before do
          @redirected_from = Article.make! :title => 'bar'
          session[:redirected_from] = 'bar'
          get :show, :id => 'foo'
        end

        it 'assigns redirection info' do
          assigns[:redirected_from].should == @redirected_from
        end

        it 'clears redirection info' do
          session[:redirected_from].should be_nil
          session[:redirection_count].should == 0
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
          response.should redirect_to('http://example.com/bar')
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
          session[:redirection_count].should == 3
        end

        it 'records the originating article' do
          get :show, :id => 'bar'
          session[:redirected_from].should == 'bar'
        end

        it 'redirects' do
          get :show, :id => 'bar'
          response.should redirect_to('/wiki/foo')
        end

        describe 'detecting a redirection loop' do
          before do
            session[:redirection_count] = 6
          end

          it 'clears the direction info' do
            get :show, :id => 'bar'
            session[:redirected_from].should be_nil
            session[:redirection_count].should == 0
          end

          it 'shows a flash' do
            get :show, :id => 'bar'
            flash[:error].should =~ /too many redirections/i
          end

          it 'redirects to #index' do
            get :show, :id => 'bar'
            response.should redirect_to('/wiki')
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
          response.should redirect_to('/wiki')
        end

        it 'shows a flash' do
          get :show, :id => 'bar'
          flash[:error].should =~ /forbidden/
        end
      end

      context 'as an admin user' do
        before do
          log_in_as_admin
        end

        it 'succeeds' do
          get :show, :id => 'bar'
          response.should be_success
        end
      end
    end

    context 'non-existent article' do
      context 'as a normal user' do
        it 'redirects to /wiki' do
          get :show, :id => 'moot'
          response.should redirect_to('/wiki')
        end

        it 'shows a flash' do
          get :show, :id => 'moot'
          flash[:error].should =~ /not found/
        end
      end

      context 'as an admin user' do
        before { log_in_as_admin }

        it 'redirects to /wiki/new' do
          get :show, :id => 'moot'
          response.should redirect_to('/wiki/new')
        end

        it 'shows a flash' do
          get :show, :id => 'moot'
          flash[:notice].should =~ /article not found: create it\?/
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
        response.should redirect_to(target)
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
        assigns[:article].should be_kind_of(Article)
        assigns[:article].should be_new_record
      end

      it 'takes params from the session' do
        session[:new_article_params] = { :title => 'foo' }
        get :new
        assigns[:article].title.should == 'foo'
      end

      it 'clears the session params' do
        session[:new_article_params] = { :title => 'foo' }
        get :new
        session[:new_article_params].should be_nil
      end
    end

    context 'non-admin access' do
      it 'redirects to the login page' do
        get :new
        response.should redirect_to('/login')
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
          assigns[:article].should be_kind_of(Article)
          assigns[:article].title.should == 'foo'
          assigns[:article].body.should == 'bar'
          assigns[:article].should be_new_record
        end

        it 'renders the preview partial' do
          xhr :post, :create, :title => 'foo', :body => 'bar'
          response.should render_template(:partial => '_preview')
        end
      end

      context 'HTML format' do
        it 'creates a new article' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          article = Article.last
          article.title.should == 'foo'
          article.body.should == 'bar'
        end

        it 'assigns the new article' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          assigns[:article].should == Article.last
        end

        it 'redirects to the article' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          article = Article.last
          response.should redirect_to(article_path(article))
        end

        it 'shows a flash' do
          post :create, :article => { :title => 'foo', :body => 'bar' }
          flash[:notice].should =~ /created new article/
        end

        context 'article with invalid params' do
          before do
            post :create, :article => { :title => 'foo' }
          end

          it 'assigns the article' do
            assigns[:article].should be_kind_of(Article)
            assigns[:article].title.should == 'foo'
            assigns[:article].should be_new_record
          end

          it 'shows an error flash' do
            flash[:error].should =~ /failed to create/i
          end

          it 'renders the #new template' do
            response.should render_template('new')
          end
        end
      end
    end

    context 'non-admin access' do
      it 'redirects to the login page' do
        post :create, :article => { :title => 'foo', :body => 'bar' }
        response.should redirect_to('/login')
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
        assigns[:article].should == @article
      end

      it 'renders the #edit template' do
        get :edit, :id => 'foo'
        response.should render_template('edit')
      end

      context 'non-existent article' do
        it 'redirects to /wiki/new' do
          get :edit, :id => 'moot'
          response.should redirect_to('/wiki/new')
        end

        it 'shows a flash' do
          get :edit, :id => 'moot'
          flash[:notice].should =~ /article not found: create it\?/
        end
      end
    end

    context 'non-admin access' do
      it 'redirects to the login page' do
        get :edit, :id => 'unimportant'
        response.should redirect_to('/login')
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
        response.should redirect_to('/login')
      end

      it 'shows a flash' do
        put :update, @params
        flash[:notice].should =~ /requires administrator privileges/
      end
    end

    context 'as an admin user' do
      before do
        log_in_as_admin
      end

      it 'updates the article' do
        put :update, @params
        Article.find_by_title!('foo').body.should == 'bar'
      end

      it 'redirects to #show' do
        put :update, @params
        response.should redirect_to('/wiki/foo')
      end

      it 'shows a flash' do
        put :update, @params
        flash[:notice].should =~ /successfully updated/i
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
          flash[:error].should =~ /update failed/i
        end

        it 'renders #edit' do
          put :update, @params
          response.should render_template('edit')
        end
      end
    end
  end
end
