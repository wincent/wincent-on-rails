require 'spec_helper'

describe Admin::ForumsController do
  describe 'routing' do
    # controller only implements #index, #show and #update
    specify { expect(get: '/admin/forums').to route_to('admin/forums#index') }
    specify { expect(get: '/admin/forums/foo').to route_to('admin/forums#show', id: 'foo') }
    specify { expect(put: '/admin/forums/foo').to route_to('admin/forums#update', id: 'foo') }

    # the remaining RESTful actions aren't recognized
    specify { expect(get: '/admin/forums/foo/edit').to_not be_routable }
    specify { expect(delete: '/admin/forums/foo').to_not be_routable }
    specify { expect(post: '/admin/forums').to_not be_routable }

    # note how in the absence of a admin/forums#new route,
    # /admin/forums/new is interpreted as admin/forums#show
    specify { expect(get: '/admin/forums/new').to route_to('admin/forums#show', id: 'new') }

    describe 'helpers' do
      let(:forum) { Forum.stub permalink: 'foo' }

      describe 'admin_forums_path' do
        specify { expect(admin_forums_path).to eq('/admin/forums') }
      end

      describe 'admin_forum_path' do
        specify { expect(admin_forum_path(forum)).to eq('/admin/forums/foo') }
      end
    end
  end
end
