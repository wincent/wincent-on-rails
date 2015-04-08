require 'spec_helper'

describe SearchController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#search' do
    it 'assigns the offset for use by the view' do
      get :search, :q => 'foo', :offset => '5'
      expect(assigns[:offset]).to eq(5)
    end

    it 'finds using the query string' do
      mock(Needle).find_with_query_string('foo', :user => nil, :offset => 0)
      get :search, :q => 'foo'
    end

    it 'uses the offset parameter when performing the query' do
      mock(Needle).find_with_query_string('foo', :user => nil, :offset => 5)
      get :search, :q => 'foo', :offset => '5'
    end

    it 'treats a missing offset value as 0' do
      mock(Needle).find_with_query_string('foo', :user => nil, :offset => 0)
      get :search, :q => 'foo', :offset => nil
    end

    it 'assigns the found models for use by the view' do
      stub(Needle).find_with_query_string(anything, anything) { :search_results }
      get :search, :q => 'foo'
      expect(assigns[:models]).to eq(:search_results)
    end
  end
end
