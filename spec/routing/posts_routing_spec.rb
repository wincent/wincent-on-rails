require 'spec_helper'

describe PostsController do
  describe 'routing' do
    specify { expect(get: '/blog').to route_to('posts#index') }
    specify { expect(get: '/blog/new').to route_to('posts#new') }
    specify { expect(get: '/blog/synergy-5.0-released').to route_to('posts#show', id: 'synergy-5.0-released') }
    specify { expect(get: '/blog/synergy-5.0-released/edit').to route_to('posts#edit', id: 'synergy-5.0-released') }
    specify { expect(put: '/blog/synergy-5.0-released').to route_to('posts#update', id: 'synergy-5.0-released') }
    specify { expect(delete: '/blog/synergy-5.0-released').to route_to('posts#destroy', id: 'synergy-5.0-released') }
    specify { expect(post: '/blog').to route_to('posts#create') }

    describe 'index pagination' do
      specify { expect(get: '/blog/page/2').to route_to('posts#index', page: '2') }

      # note how we can still have an post titled "Page"
      specify { expect(get: '/blog/page').to route_to('posts#show', id: 'page') }

      it 'rejects non-numeric :page params' do
        expect(get: '/blog/page/foo').to_not be_routable
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { expect(get: '/blog/synergy-5.0-released/comments/new').to route_to('comments#new', post_id: 'synergy-5.0-released') }
      specify { expect(post: '/blog/synergy-5.0-released/comments').to route_to('comments#create', post_id: 'synergy-5.0-released') }
      specify { expect(put: '/blog/synergy-5.0-released/comments/123').to route_to('comments#update', post_id: 'synergy-5.0-released', id: '123') }

      # all other RESTful actions are no-ops
      specify { expect(get: '/blog/synergy-5.0-released/comments').to_not be_routable }
      specify { expect(get: '/blog/synergy-5.0-released/comments/456').to_not be_routable }
      specify { expect(get: '/blog/synergy-5.0-released/comments/456/edit').to_not be_routable }
      specify { expect(delete: '/blog/synergy-5.0-released/comments/456').to_not be_routable }
    end

    describe 'regressions' do
      it 'handles trailing slashes on resources declared using ":as"' do
        # bug appeared in Rails 2.3.0 RC1; see:
        #   http://rails.lighthouseapp.com/projects/8994/tickets/2039
        expect(get: '/blog/').to route_to('posts#index')
      end

      it 'handles comment creation on posts with periods in the title' do
        # see: https://wincent.com/issues/1410
        expect(post: '/blog/foo.bar/comments').to route_to('comments#create', post_id: 'foo.bar')
      end
    end

    describe 'helpers' do
      let(:post) do
        # we use an post with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        Post.stub permalink: 'synergy-5.0-released'
      end

      describe 'posts_path' do
        specify { expect(posts_path).to eq('/blog') }
      end

      describe 'new_post_path' do
        specify { expect(new_post_path).to eq('/blog/new') }
      end

      describe 'post_path' do
        specify { expect(post_path(post)).to eq('/blog/synergy-5.0-released') }
      end

      describe 'edit_post_path' do
        specify { expect(edit_post_path(post)).to eq('/blog/synergy-5.0-released/edit') }
      end
    end
  end
end
