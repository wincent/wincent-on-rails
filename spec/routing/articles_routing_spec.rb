require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ArticlesController do
  describe 'routing' do
    example 'GET /wiki' do
      get('/wiki').should map('articles#index')
    end

    example 'GET /wiki/new' do
      get('/wiki/new').should map('articles#new')
    end

    example 'GET /wiki/:id' do
      get('/wiki/Rails_3.0_upgrade_notes').should map('articles#show', :id => 'Rails_3.0_upgrade_notes')
    end

    example 'GET /wiki/:id/edit' do
      get('/wiki/Rails_3.0_upgrade_notes/edit').should map('articles#edit', :id => 'Rails_3.0_upgrade_notes')
    end

    example 'PUT /wiki/:id' do
      put('/wiki/Rails_3.0_upgrade_notes').should map('articles#update', :id => 'Rails_3.0_upgrade_notes')
    end

    example 'DELETE /wiki/:id' do
      delete('/wiki/Rails_3.0_upgrade_notes').should map('articles#destroy', :id => 'Rails_3.0_upgrade_notes')
    end

    example 'POST /wiki' do
      post('/wiki').should map('articles#create')
    end

    describe 'index pagination' do
      example 'GET /wiki/page/2' do
        get('/wiki/page/2').should map_to('articles#index', :page => '2')
      end

      # note how we can still have an article titled "Page"
      example 'GET /wiki/page' do
        get('/wiki/page').should map('articles#show', :id => 'page')
      end
    end

    describe 'regressions' do
      it 'handles trailing slashes on resources declared using ":as"' do
        # bug appeared in Rails 2.3.0 RC1; see:
        #   http://rails.lighthouseapp.com/projects/8994/tickets/2039
        get('/wiki/').should map_to('articles#index')
      end

      it 'handles comment creation on articles with periods in the title' do
        # see: https://wincent.com/issues/1410
        post('/wiki/foo.bar/comments').should map_to('comments#create', :article_id => 'foo.bar')
      end
    end

    describe 'helpers' do
      before do
        # we use an article with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        @article = Article.make! :title => 'Rails 3.0 upgrade notes'
      end

      it { articles_path.should == '/wiki' }
      it { new_article_path.should == '/wiki/new' }
      it { article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes' }
      it { edit_article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes/edit' }
      it { paginated_articles_path(:page => 2).should == '/wiki/page/2' }
    end
  end
end
