require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'hpricot'

# A note about Atom format testing:
#
# For most resources we can test using requests like:
#
#   get :show, :id => 'foo', :format => 'show'
#
# But the Article resource is special because it allows periods, which Rails
# usually considers as format separators, in its permalinks.
#
# This means that requests made to the articles controller such as GET
# /wiki/foo.atom do not actually come with the :format parameter set as one
# would usually expect. Instead the controller gets passed an :id of
# "foo.atom" and it is up to the controller to detect that it is actually an
# Atom request.
#
# At test time this means that we must express our requests in the form of:
#
#   get :show, :id => 'foo.atom'
#
# Only then can we properly test the code path in the controller which handles
# this kind of request (specifically, the "get_article" method).
#
# There is one exception to this rule and that is where we wish to test layouts
# as well (for example, to confirm that we produce a valid Atom feed we must
# ensure that we don't end up rendering views inside the HTML application
# layout). In this case we must do:
#
#   get :show, :id => 'foo.atom', :format => 'atom'
#
# Otherwise the test machinery will render the template in the default HTML
# application layout. Note that in practice Rails will never send an explicit
# Atom :format parameter to this controller, but supplying one here is a
# necessary evil to force the test machinery to do the right thing.
describe ArticlesController do
  describe '#index' do
    context 'HTML format' do
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
        mock(Article).recent_with_offset.with_any_args
        get :index
      end

      it 'assigns found articles' do
        articles = [Article.make!]
        stub(Article).recent_with_offset.with_any_args { articles }
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

    context 'Atom format' do
      render_views # needed otherwise test machinery uses HTML layout

      it 'finds recent articles, excluding redirects' do
        mock(Article).recent_excluding_redirects { [] }
        get :index, :format => 'atom'
      end

      it 'assigns found articles' do
        articles = [Article.make!]
        stub(Article).recent_excluding_redirects { articles }
        get :index, :format => 'atom'
        assigns[:articles].should == articles
      end

      it 'succeeds' do
        get :index, :format => 'atom'
      end

      it 'renders the index template' do
        get :index, :format => 'atom'
        response.should render_template('index')
      end

      describe 'regressions' do
        before do
          10.times { Article.make! }
        end

        # https://wincent.com/issues/1227
        it 'produces valid atom when there are no articles' do
          pending unless can_validate_feeds?
          Article.destroy_all
          get :index, :format => 'atom'
          response.body.should be_valid_atom
        end

        it 'produces valid atom when there are multiple articles' do
          pending unless can_validate_feeds?
          get :index, :format => 'atom'
          response.body.should be_valid_atom
        end

        # http://rails.lighthouseapp.com/projects/8994/tickets/2043
        it 'should produce entry links to HTML-formatted records' do
          get :index, :format => 'atom'
          doc = Hpricot.XML(response.body)
          (doc/:entry).collect do |entry|
            (entry/:link).first[:href].each do |href|
              # make sure links are /wiki/foo, not /wiki/foo.atom
              href.should_not =~ %r{\.html\z}
            end
          end
        end
      end
    end
  end

  describe '#show' do
    context 'HTML format' do
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
          assigns[:comments].should =~ @comments
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
              cookie_flash['error'].should =~ /too many redirections/i
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
            cookie_flash['error'].should =~ /forbidden/
          end
        end

        context 'as an admin user' do
          it 'succeeds' do
            as_admin do
              get :show, :id => 'bar'
              response.should be_success
            end
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

    context 'Atom format' do
      context 'public article' do
        before do
          @article = Article.make! :title => 'foo'
          @comments = Array.new(5) { Comment.make! :commentable => @article }
        end

        it 'assigns the article' do
          get :show, :id => 'foo.atom'
          assigns[:article].should == @article
        end

        it 'assigns existing comments' do
          get :show, :id => 'foo.atom'
          assigns[:comments].should =~ @comments
        end

        it 'succeeds' do
          get :show, :id => 'foo.atom'
          response.should be_success
        end

        it 'renders the show template' do
          get :show, :id => 'foo.atom'
          response.should render_template('show')
        end
      end

      context 'private article' do
        before do
          @article = Article.make! :title => 'bar', :public => false
        end

        it 'returns 403 forbidden' do
          get :show, :id => 'bar.atom'
          response.status.should == 403
        end
      end

      describe 'regressions' do
        render_views # needed otherwise test machinery uses HTML layout

        before do
          @article = Article.make! :title => 'foo bar baz'
        end

        def do_get
          # need :format param here or test machinery will render HTML template
          get :show, :id => 'foo_bar_baz.atom', :format => 'atom'
        end

        # https://wincent.com/issues/1227
        it 'produces valid atom when there are no comments' do
          pending unless can_validate_feeds?
          do_get
          response.body.should be_valid_atom
        end

        it 'produces valid atom when there are multiple comments' do
          pending unless can_validate_feeds?
          10.times { Comment.make! :commentable => @article }
          do_get
          response.body.should be_valid_atom
        end
      end
    end
  end
end
