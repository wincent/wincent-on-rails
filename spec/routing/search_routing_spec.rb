require 'spec_helper'

describe SearchController do
  describe 'routing' do
    specify { expect(get: '/search').to route_to('search#search') }

    describe 'helpers' do
      describe 'search_path' do
        specify { expect(search_path).to eq('/search') }
      end
    end
  end
end
