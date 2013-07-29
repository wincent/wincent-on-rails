require 'spec_helper'

describe TagsController do
  describe 'routing' do
    specify { expect(get: '/tags').to route_to('tags#index') }
    specify { expect(get: '/tags/new').to route_to('tags#new') }
    specify { expect(get: '/tags/foo.bar').to route_to('tags#show', id: 'foo.bar') }
    specify { expect(get: '/tags/foo.bar/edit').to route_to('tags#edit', id: 'foo.bar') }
    specify { expect(put: '/tags/foo.bar').to route_to('tags#update', id: 'foo.bar') }
    specify { expect(delete: '/tags/foo.bar').to route_to('tags#destroy', id: 'foo.bar') }
    specify { expect(post: '/tags').to route_to('tags#create') }

    it 'rejects invalid tag names' do
      # only letters, numbers and periods allowed
      expect(get: '/tags/foo-bar').to_not be_routable

      # counter-example
      expect(get: '/tags/foo.2').to route_to('tags#show', id: 'foo.2')
    end

    describe 'non-RESTful routes' do
      specify { expect(get: '/tags/search').to route_to('tags#search') }
    end

    describe 'helpers' do
      let(:tag) do
        # we use an tag with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        Tag.stub name: 'foo.bar'
      end

      describe 'tags_path' do
        specify { expect(tags_path).to eq('/tags') }
      end

      describe 'new_tag_path' do
        specify { expect(new_tag_path).to eq('/tags/new') }
      end

      describe 'tag_path' do
        specify { expect(tag_path(tag)).to eq('/tags/foo.bar') }
      end

      describe 'edit_tag_path' do
        specify { expect(edit_tag_path(tag)).to eq('/tags/foo.bar/edit') }
      end

      describe 'search_tags_path' do
        specify { expect(search_tags_path).to eq('/tags/search') }
      end
    end
  end
end
