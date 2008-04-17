require File.dirname(__FILE__) + '/../spec_helper'

describe IssuesController do
  describe 'RESTful route generation' do
    it "should map { :controller => 'issues', :action => 'index' } to /issues" do
      route_for(:controller => 'issues', :action => 'index').should == '/issues'
    end

    it "should map { :controller => 'issues', :action => 'new' } to /issues/new" do
      route_for(:controller => 'issues', :action => 'new').should == '/issues/new'
    end

    it "should map { :controller => 'issues', :action => 'show', :id => '123' } to /issues/123" do
      route_for(:controller => 'issues', :action => 'show', :id => '123').should == '/issues/123'
    end

    it "should map { :controller => 'issues', :action => 'edit', :id => '123' } to /issues/123/edit" do
      route_for(:controller => 'issues', :action => 'edit', :id => '123').should == '/issues/123/edit'
    end

    it "should map { :controller => 'issues', :action => 'update', :id => '123' } to /issues/123" do
      route_for(:controller => 'issues', :action => 'update', :id => '123').should == '/issues/123'
    end

    it "should map { :controller => 'issues', :action => 'destroy', :id => '123' } to /issues/123" do
      route_for(:controller => 'issues', :action => 'destroy', :id => '123').should == '/issues/123'
    end
  end

  describe 'non-RESTful route recognition' do
    it "should map { :controller => 'issues', :action => 'search' } to /issues/search" do
      route_for(:controller => 'issues', :action => 'search').should == '/issues/search'
    end
  end

  describe 'RESTful route recognition' do
    it "should generate params { :controller => 'issues', action => 'index' } from GET /issues" do
      params_from(:get, '/issues').should == { :controller => 'issues', :action => 'index' }
    end

    it "should generate params { :controller => 'issues', action => 'new' } from GET /issues/new" do
      params_from(:get, '/issues/new').should == { :controller => 'issues', :action => 'new' }
    end

    it "should generate params { :controller => 'issues', action => 'create' } from POST /issues" do
      params_from(:post, '/issues').should == { :controller => 'issues', :action => 'create' }
    end

    it "should generate params { :controller => 'issues', action => 'show', id => '123' } from GET /issues/123" do
      params_from(:get, '/issues/123').should == { :controller => 'issues', :action => 'show', :id => '123' }
    end

    it "should generate params { :controller => 'issues', action => 'edit', id => '123' } from GET /issues/123;edit" do
      params_from(:get, '/issues/123/edit').should == { :controller => 'issues', :action => 'edit', :id => '123' }
    end

    it "should generate params { :controller => 'issues', action => 'update', id => '123' } from PUT /issues/123" do
      params_from(:put, '/issues/123').should == { :controller => 'issues', :action => 'update', :id => '123' }
    end

    it "should generate params { :controller => 'issues', action => 'destroy', id => '123' } from DELETE /issues/123" do
      params_from(:delete, '/issues/123').should == { :controller => 'issues', :action => 'destroy', :id => '123' }
    end
  end

  describe 'non-RESTful route recognition' do
    it "should generate params { :controller => 'issues', action => 'search' } from GET /issues/search" do
      params_from(:get, '/issues/search').should == { :controller => 'issues', :action => 'search' }
    end

    it "should generate params { :controller => 'issues', action => 'search' } from POST /issues/search" do
      params_from(:post, '/issues/search').should == { :controller => 'issues', :action => 'search' }
    end
  end
end
