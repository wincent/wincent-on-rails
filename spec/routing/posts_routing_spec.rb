require 'spec_helper'

describe PostsController do
  describe 'routing' do
    specify { get('/blog').should have_routing('posts#index') }
    specify { get('/blog/new').should have_routing('posts#new') }
    specify { get('/blog/synergy-5.0-released').should have_routing('posts#show', :id => 'synergy-5.0-released') }
    specify { get('/blog/synergy-5.0-released/edit').should have_routing('posts#edit', :id => 'synergy-5.0-released') }
    specify { put('/blog/synergy-5.0-released').should have_routing('posts#update', :id => 'synergy-5.0-released') }
    specify { delete('/blog/synergy-5.0-released').should have_routing('posts#destroy', :id => 'synergy-5.0-released') }
    specify { post('/blog').should have_routing('posts#create') }

    describe 'index pagination' do
      specify { get('/blog/page/2').should map_to('posts#index', :page => '2') }

      # note how we can still have an post titled "Page"
      specify { get('/blog/page').should have_routing('posts#show', :id => 'page') }

      it 'rejects non-numeric :page params' do
        get('/blog/page/foo').should_not be_recognized
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { get('/blog/synergy-5.0-released/comments/new').should have_routing('comments#new', :post_id => 'synergy-5.0-released') }
      specify { post('/blog/synergy-5.0-released/comments').should have_routing('comments#create', :post_id => 'synergy-5.0-released') }
      specify { put('/blog/synergy-5.0-released/comments/456').should have_routing('comments#update', :post_id => 'synergy-5.0-released', :id => '456') }

      # all other RESTful actions are no-ops
      specify { get('/blog/synergy-5.0-released/comments').should_not be_recognized }
      specify { get('/blog/synergy-5.0-released/comments/456').should_not be_recognized }
      specify { get('/blog/synergy-5.0-released/comments/456/edit').should_not be_recognized }
      specify { delete('/blog/synergy-5.0-released/comments/456').should_not be_recognized }
    end

    describe 'regressions' do
      it 'handles trailing slashes on resources declared using ":as"' do
        # bug appeared in Rails 2.3.0 RC1; see:
        #   http://rails.lighthouseapp.com/projects/8994/tickets/2039
        get('/blog/').should map_to('posts#index')
      end

      it 'handles comment creation on posts with periods in the title' do
        # see: https://wincent.com/issues/1410
        post('/blog/foo.bar/comments').should map_to('comments#create', :post_id => 'foo.bar')
      end
    end

    describe 'helpers' do
      before do
        # we use an post with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        @post = Post.stub :permalink => 'synergy-5.0-released'
      end

      describe 'posts_path' do
        specify { posts_path.should == '/blog' }
      end

      describe 'new_post_path' do
        specify { new_post_path.should == '/blog/new' }
      end

      describe 'post_path' do
        specify { post_path(@post).should == '/blog/synergy-5.0-released' }
      end

      describe 'edit_post_path' do
        specify { edit_post_path(@post).should == '/blog/synergy-5.0-released/edit' }
      end
    end
  end
end
