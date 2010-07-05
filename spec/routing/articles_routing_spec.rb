require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ArticlesController do
  describe 'routing' do
    it { get('/wiki').should map('articles#index') }
    it { get('/wiki/new').should map('articles#new') }
    it { get('/wiki/Rails_3.0_upgrade_notes').should map('articles#show', :id => 'Rails_3.0_upgrade_notes') }
    it { get('/wiki/Rails_3.0_upgrade_notes/edit').should map('articles#edit', :id => 'Rails_3.0_upgrade_notes') }
    it { put('/wiki/Rails_3.0_upgrade_notes').should map('articles#update', :id => 'Rails_3.0_upgrade_notes') }
    it { delete('/wiki/Rails_3.0_upgrade_notes').should map('articles#destroy', :id => 'Rails_3.0_upgrade_notes') }
    it { post('/wiki').should map('articles#create') }

    describe 'index pagination' do
      it { get('/wiki/page/2').should map_to('articles#index', :page => '2') }

      # note how we can still have an article titled "Page"
      it { get('/wiki/page').should map('articles#show', :id => 'page') }
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
        @article = Article.stub :title => 'Rails 3.0 upgrade notes'
      end

      describe 'articles_path' do
        it { articles_path.should == '/wiki' }
      end

      describe 'new_article_path' do
        it { new_article_path.should == '/wiki/new' }
      end

      describe 'article_path' do
        it { article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes' }
      end

      describe 'edit_article_path' do
        it { edit_article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes/edit' }
      end
    end
  end
end
