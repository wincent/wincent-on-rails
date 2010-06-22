require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_controller_spec'

describe SearchesController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end

describe SearchesController, 'create action' do
  it 'should assign the offset for use by the view' do
    post :create, :offset => '5', :protocol => 'https'
    assigns[:offset].should == 5
  end

  it 'should find using the query string' do
    Needle.should_receive(:find_using_query_string).with('foo', :user => nil, :offset => 0)
    post :create, :query => 'foo', :protocol => 'https'
  end

  it 'should should pass a nil query parameter as an empty string' do
    # this is low cost and prevents an exception being thrown in the face of bad input (possible attack)
    Needle.should_receive(:find_using_query_string).with('', :user => nil, :offset => 0)
    post :create, :protocol => 'https'
  end

  it 'should use the offset parameter when performing the query' do
    Needle.should_receive(:find_using_query_string).with('foo', :user => nil, :offset => 5)
    post :create, :query => 'foo', :offset => '5', :protocol => 'https'
  end

  it 'should treat a missing offset value as 0' do
    Needle.should_receive(:find_using_query_string).with('foo', :user => nil, :offset => 0)
    post :create, :query => 'foo', :offset => nil, :protocol => 'https'
  end

  it 'should assign the found models for use by the view' do
    Needle.stub!(:find_using_query_string).and_return(:search_results)
    post :create, :protocol => 'https'
    assigns[:models].should == :search_results
  end
end
