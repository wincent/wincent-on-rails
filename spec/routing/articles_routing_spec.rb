require 'spec_helper'

describe ArticlesController do
  describe 'routing' do
    specify { expect(get: '/wiki').to route_to('articles#index') }
    specify { expect(get: '/wiki/new').to route_to('articles#new') }
    specify { expect(get: '/wiki/Rails_3.0_upgrade_notes').to route_to('articles#show', id: 'Rails_3.0_upgrade_notes') }
    specify { expect(get: '/wiki/Rails_3.0_upgrade_notes/edit').to route_to('articles#edit', id: 'Rails_3.0_upgrade_notes') }
    specify { expect(put: '/wiki/Rails_3.0_upgrade_notes').to route_to('articles#update', id: 'Rails_3.0_upgrade_notes') }
    specify { expect(delete: '/wiki/Rails_3.0_upgrade_notes').to route_to('articles#destroy', id: 'Rails_3.0_upgrade_notes') }
    specify { expect(post: '/wiki').to route_to('articles#create') }

    describe 'index pagination' do
      specify { expect(get: '/wiki/page/2').to route_to('articles#index', page: '2') }

      # note how we can still have an article titled "Page"
      specify { expect(get: '/wiki/page').to route_to('articles#show', id: 'page') }

      it 'rejects non-numeric :page params' do
        expect(get: '/wiki/page/foo').to_not be_routable
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { expect(get: '/wiki/Rails_3.0_upgrade_notes/comments/new').to route_to('comments#new', article_id: 'Rails_3.0_upgrade_notes') }
      specify { expect(post: '/wiki/Rails_3.0_upgrade_notes/comments').to route_to('comments#create', article_id: 'Rails_3.0_upgrade_notes') }
      specify { expect(put: '/wiki/Rails_3.0_upgrade_notes/comments/456').to route_to('comments#update', article_id: 'Rails_3.0_upgrade_notes', id: '456') }

      # all other RESTful actions are no-ops
      specify { expect(get: '/wiki/Rails_3.0_upgrade_notes/comments').to_not be_routable }
      specify { expect(get: '/wiki/Rails_3.0_upgrade_notes/comments/456').to_not be_routable }
      specify { expect(get: '/wiki/Rails_3.0_upgrade_notes/comments/456/edit').to_not be_routable }
      specify { expect(delete: '/wiki/Rails_3.0_upgrade_notes/comments/456').to_not be_routable }
    end

    describe 'regressions' do
      it 'handles trailing slashes on resources declared using ":as"' do
        # bug appeared in Rails 2.3.0 RC1; see:
        #   http://rails.lighthouseapp.com/projects/8994/tickets/2039
        expect(get: '/wiki/').should route_to('articles#index')
      end

      it 'handles comment creation on articles with periods in the title' do
        # see: https://wincent.com/issues/1410
        expect(post: '/wiki/foo.bar/comments').should route_to('comments#create', article_id: 'foo.bar')
      end
    end

    describe 'helpers' do
      let(:article) do
        # we use an article with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        Article.stub title: 'Rails 3.0 upgrade notes'
      end

      describe 'articles_path' do
        specify { expect(articles_path).to eq('/wiki') }
      end

      describe 'new_article_path' do
        specify { expect(new_article_path).to eq('/wiki/new') }
      end

      describe 'article_path' do
        specify { expect(article_path(article)).to eq('/wiki/Rails_3.0_upgrade_notes') }
      end

      describe 'edit_article_path' do
        specify { expect(edit_article_path(article)).to eq('/wiki/Rails_3.0_upgrade_notes/edit') }
      end
    end
  end
end
