require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe PostsController do
  describe 'routing' do
    specify { get('/blog').should map('posts#index') }
    specify { get('/blog/new').should map('posts#new') }
    specify { get('/blog/synergy-5.0-released').should map('posts#show', :id => 'synergy-5.0-released') }
    specify { get('/blog/synergy-5.0-released/edit').should map('posts#edit', :id => 'synergy-5.0-released') }
    specify { put('/blog/synergy-5.0-released').should map('posts#update', :id => 'synergy-5.0-released') }
    specify { delete('/blog/synergy-5.0-released').should map('posts#destroy', :id => 'synergy-5.0-released') }
    specify { post('/blog').should map('posts#create') }

    describe 'index pagination' do
      specify { get('/blog/page/2').should map_to('posts#index', :page => '2') }

      # note how we can still have an post titled "Page"
      specify { get('/blog/page').should map('posts#show', :id => 'page') }

      it 'rejects non-numeric :page params' do
        get('/blog/page/foo').should_not be_recognized
      end
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
