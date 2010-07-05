require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe PostsController do
  describe 'routing' do
    it { get('/blog').should map('posts#index') }
    it { get('/blog/new').should map('posts#new') }
    it { get('/blog/synergy-5.0-released').should map('posts#show', :id => 'synergy-5.0-released') }
    it { get('/blog/synergy-5.0-released/edit').should map('posts#edit', :id => 'synergy-5.0-released') }
    it { put('/blog/synergy-5.0-released').should map('posts#update', :id => 'synergy-5.0-released') }
    it { delete('/blog/synergy-5.0-released').should map('posts#destroy', :id => 'synergy-5.0-released') }
    it { post('/blog').should map('posts#create') }

    describe 'index pagination' do
      it { get('/blog/page/2').should map_to('posts#index', :page => '2') }

      # note how we can still have an post titled "Page"
      it { get('/blog/page').should map('posts#show', :id => 'page') }
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
        it { posts_path.should == '/blog' }
      end

      describe 'new_post_path' do
        it { new_post_path.should == '/blog/new' }
      end

      describe 'post_path' do
        it { post_path(@post).should == '/blog/synergy-5.0-released' }
      end

      describe 'edit_post_path' do
        it { edit_post_path(@post).should == '/blog/synergy-5.0-released/edit' }
      end
    end
  end
end
