require 'spec_helper'

describe SearchController do
  describe 'routing' do
    specify do
      get('/search').should have_routing('search#search')
    end

    describe 'helpers' do
      describe 'search_path' do
        specify { search_path.should == '/search' }
      end
    end
  end
end
