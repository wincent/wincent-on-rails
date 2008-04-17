require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_spec'

describe IssuesController do
  it_should_behave_like 'ApplicationController'
end

describe IssuesController, 'GET /issues/search' do
  # these tests are fairly weak at the moment because I don't want to start mocking the internal implementation details
  # too much (I may already have gone too far); I will add fuller specs later which test only the external behaviour
  it 'should check the default_access_options' do
    controller.should_receive(:default_access_options)
    get :search
  end

  it 'should sanitize the search parameters' do
    Issue.should_receive(:prepare_search_conditions)
    get :search
  end

  it "should propagate the user's sort options" do
    controller.should_receive(:sort_options).and_return({})
    get :search
  end

  it 'should find all applicable issues' do
    Issue.should_receive(:find)
    get :search
  end
end
