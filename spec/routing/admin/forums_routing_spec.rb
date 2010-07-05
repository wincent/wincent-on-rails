require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Admin::ForumsController do
  describe 'routing' do
    # controller only implements #index, #show and #update
    specify { get('/admin/forums').should map('admin/forums#index') }
    specify { get('/admin/forums/foo').should map('admin/forums#show', :id => 'foo') }
    specify { put('/admin/forums/foo').should map('admin/forums#update', :id => 'foo') }

    # the remaining RESTful actions aren't recognized
    pending { get('/admin/forums/new').should_not be_recognized }
    pending { get('/admin/forums/foo/edit').should_not be_recognized }
    pending { delete('/admin/forums/foo').should_not be_recognized }
    pending { post('/admin/forums').should_not be_recognized }

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
