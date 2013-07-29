require 'spec_helper'

describe LinksController do
  describe 'routing' do
    specify { expect(get: '/links').to route_to('links#index') }
    specify { expect(get: '/links/new').to route_to('links#new') }
    specify { expect(get: '/links/foo').to route_to('links#show', id: 'foo') }
    specify { expect(get: '/links/foo/edit').to route_to('links#edit', id: 'foo') }
    specify { expect(put: '/links/foo').to route_to('links#update', id: 'foo') }
    specify { expect(delete: '/links/foo').to route_to('links#destroy', id: 'foo') }
    specify { expect(post: '/links').to route_to('links#create') }

    # shortcut
    specify { expect(get: 'l/foo').to route_to('links#show', id: 'foo') }

    describe 'helpers' do
      let(:link) { Link.stub permalink: 'foo' }

      describe 'links_path' do
        specify { expect(links_path).to eq('/links') }
      end

      describe 'new_link_path' do
        specify { expect(new_link_path).to eq('/links/new') }
      end

      describe 'link_path' do
        specify { expect(link_path(link)).to eq('/links/foo') }
      end

      describe 'edit_link_path' do
        specify { expect(edit_link_path(link)).to eq('/links/foo/edit') }
      end

      describe 'edit_link_path' do
        specify { expect(edit_link_path(link)).to eq('/links/foo/edit') }
      end
    end
  end
end
