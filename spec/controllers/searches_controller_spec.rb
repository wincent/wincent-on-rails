require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe SearchesController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end

describe SearchesController, '#create' do
  it 'assigns the offset for use by the view' do
    post :create, :offset => '5', :protocol => 'https'
    assigns[:offset].should == 5
  end

  it 'finds using the query string' do
    mock(Needle).find_using_query_string('foo', :user => nil, :offset => 0)
    post :create, :query => 'foo'
  end

  it 'passes a nil query parameter as an empty string' do
    # this is low cost and prevents an exception being thrown in the face of bad input (possible attack)
    mock(Needle).find_using_query_string('', :user => nil, :offset => 0)
    post :create
  end

  it 'uses the offset parameter when performing the query' do
    mock(Needle).find_using_query_string('foo', :user => nil, :offset => 5)
    post :create, :query => 'foo', :offset => '5'
  end

  it 'treats a missing offset value as 0' do
    mock(Needle).find_using_query_string('foo', :user => nil, :offset => 0)
    post :create, :query => 'foo', :offset => nil
  end

  it 'assigns the found models for use by the view' do
    stub(Needle).find_using_query_string(anything, anything) { :search_results }
    post :create
    assigns[:models].should == :search_results
  end
end
