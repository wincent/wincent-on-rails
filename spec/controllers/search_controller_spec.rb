require 'spec_helper'

describe SearchController do
  it_has_behavior 'ApplicationController protected methods'

  describe '#search' do
    it 'assigns the offset for use by the view' do
      get :search, :q => 'foo', :offset => '5'
      assigns[:offset].should == 5
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
      assigns[:models].should == :search_results
    end
  end
end
