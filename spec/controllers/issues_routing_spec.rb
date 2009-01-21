require File.dirname(__FILE__) + '/../spec_helper'

describe IssuesController do
  describe 'RESTful route generation' do
    it "should map { :controller => 'issues', :action => 'index', :protocol => 'https' } to /issues" do
      route_for(:controller => 'issues', :action => 'index', :protocol => 'https').should == '/issues'
    end

    it "should map { :controller => 'issues', :action => 'new', :protocol => 'https' } to /issues/new" do
      route_for(:controller => 'issues', :action => 'new', :protocol => 'https').should == '/issues/new'
    end

    it "should map { :controller => 'issues', :action => 'show', :id => '123', :protocol => 'https' } to /issues/123" do
      route_for(:controller => 'issues', :action => 'show', :id => '123', :protocol => 'https').should == '/issues/123'
    end

    it "should map { :controller => 'issues', :action => 'edit', :id => '123', :protocol => 'https' } to /issues/123/edit" do
      route_for(:controller => 'issues', :action => 'edit', :id => '123', :protocol => 'https').should == '/issues/123/edit'
    end

    it "should map { :controller => 'issues', :action => 'update', :id => '123', :protocol => 'https' } to /issues/123" do
      route_for(:controller => 'issues', :action => 'update', :id => '123', :protocol => 'https').should == '/issues/123'
    end

    it "should map { :controller => 'issues', :action => 'destroy', :id => '123', :protocol => 'https' } to /issues/123" do
      route_for(:controller => 'issues', :action => 'destroy', :id => '123', :protocol => 'https').should == '/issues/123'
    end
  end

  describe 'non-RESTful route generation' do
    it "should map { :controller => 'issues', :action => 'search', :protocol => 'https' } to /issues/search" do
      route_for(:controller => 'issues', :action => 'search', :protocol => 'https').should == '/issues/search'
    end
  end

  describe 'RESTful route recognition' do
    it "should generate params { :controller => 'issues', action => 'index', :protocol => 'https' } from GET /issues" do
      params_from(:get, '/issues').should == { :controller => 'issues', :action => 'index', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'new', :protocol => 'https' } from GET /issues/new" do
      params_from(:get, '/issues/new').should == { :controller => 'issues', :action => 'new', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'create', :protocol => 'https' } from POST /issues" do
      params_from(:post, '/issues').should == { :controller => 'issues', :action => 'create', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'show', id => '123', :protocol => 'https' } from GET /issues/123" do
      params_from(:get, '/issues/123').should == { :controller => 'issues', :action => 'show', :id => '123', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'edit', id => '123', :protocol => 'https' } from GET /issues/123;edit" do
      params_from(:get, '/issues/123/edit').should == { :controller => 'issues', :action => 'edit', :id => '123', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'update', id => '123', :protocol => 'https' } from PUT /issues/123" do
      params_from(:put, '/issues/123').should == { :controller => 'issues', :action => 'update', :id => '123', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'destroy', id => '123', :protocol => 'https' } from DELETE /issues/123" do
      params_from(:delete, '/issues/123').should == { :controller => 'issues', :action => 'destroy', :id => '123', :protocol => 'https' }
    end
  end

  describe 'non-RESTful route recognition' do
    it "should generate params { :controller => 'issues', action => 'search', :protocol => 'https' } from GET /issues/search" do
      params_from(:get, '/issues/search').should == { :controller => 'issues', :action => 'search', :protocol => 'https' }
    end

    it "should generate params { :controller => 'issues', action => 'search', :protocol => 'https' } from POST /issues/search" do
      # one wart remains in the move from HTTP to HTTPS: the "search" action, which is defined as a "collection"
      # does not get the protocol right ("https") during recognition (but generation is ok)
      params_from(:post, '/issues/search').should == { :controller => 'issues', :action => 'search' }
    end
  end
end
