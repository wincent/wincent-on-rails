require 'spec_helper'

describe Admin::ForumsController do
  describe 'routing' do
    # controller only implements #index, #show and #update
    specify { get('/admin/forums').should have_routing('admin/forums#index') }
    specify { get('/admin/forums/foo').should have_routing('admin/forums#show', :id => 'foo') }
    specify { put('/admin/forums/foo').should have_routing('admin/forums#update', :id => 'foo') }

    # the remaining RESTful actions aren't recognized
    specify { get('/admin/forums/foo/edit').should_not be_recognized }
    specify { delete('/admin/forums/foo').should_not be_recognized }
    specify { post('/admin/forums').should_not be_recognized }

    # note how in the absence of a admin/forums#new route,
    # /admin/forums/new is interpreted as admin/forums#show
    specify { get('/admin/forums/new').should have_routing('admin/forums#show', :id => 'new') }

    describe 'helpers' do
      before do
        @forum = Forum.stub :permalink => 'foo'
      end

      describe 'admin_forums_path' do
        it { admin_forums_path.should == '/admin/forums' }
      end

      describe 'admin_forum_path' do
        it { admin_forum_path(@forum).should == '/admin/forums/foo' }
      end
    end
  end
end
