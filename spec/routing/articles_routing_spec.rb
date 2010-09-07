require 'spec_helper'

describe ArticlesController do
  describe 'routing' do
    specify { get('/wiki').should have_routing('articles#index') }
    specify { get('/wiki/new').should have_routing('articles#new') }
    specify { get('/wiki/Rails_3.0_upgrade_notes').should have_routing('articles#show', :id => 'Rails_3.0_upgrade_notes') }
    specify { get('/wiki/Rails_3.0_upgrade_notes/edit').should have_routing('articles#edit', :id => 'Rails_3.0_upgrade_notes') }
    specify { put('/wiki/Rails_3.0_upgrade_notes').should have_routing('articles#update', :id => 'Rails_3.0_upgrade_notes') }
    specify { delete('/wiki/Rails_3.0_upgrade_notes').should have_routing('articles#destroy', :id => 'Rails_3.0_upgrade_notes') }
    specify { post('/wiki').should have_routing('articles#create') }

    describe 'index pagination' do
      specify { get('/wiki/page/2').should map_to('articles#index', :page => '2') }

      # note how we can still have an article titled "Page"
      specify { get('/wiki/page').should have_routing('articles#show', :id => 'page') }

      it 'rejects non-numeric :page params' do
        get('/wiki/page/foo').should_not be_recognized
      end
    end

    describe 'comments' do
      # only #new and #create are implemented while nested
      # Rails BUG?: only map_to works here; map_from (and therefore also have_routing) do not
      specify { get('/wiki/Rails_3.0_upgrade_notes/comments/new').should map_to('comments#new', :article_id => 'Rails_3.0_upgrade_notes') }
      specify { post('/wiki/Rails_3.0_upgrade_notes/comments').should map_to('comments#create', :article_id => 'Rails_3.0_upgrade_notes') }

      # all other RESTful actions are no-ops
      specify { get('/wiki/Rails_3.0_upgrade_notes/comments').should_not be_recognized }
      specify { get('/wiki/Rails_3.0_upgrade_notes/comments/456').should_not be_recognized }
      specify { get('/wiki/Rails_3.0_upgrade_notes/comments/456/edit').should_not be_recognized }
      specify { put('/wiki/Rails_3.0_upgrade_notes/comments/456').should_not be_recognized }
      specify { delete('/wiki/Rails_3.0_upgrade_notes/comments/456').should_not be_recognized }
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
        specify { articles_path.should == '/wiki' }
      end

      describe 'new_article_path' do
        specify { new_article_path.should == '/wiki/new' }
      end

      describe 'article_path' do
        specify { article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes' }
      end

      describe 'edit_article_path' do
        specify { edit_article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes/edit' }
      end
    end
  end
end
