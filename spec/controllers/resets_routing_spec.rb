require File.dirname(__FILE__) + '/../spec_helper'

describe ResetsController do
  describe 'route generation' do
    it "should map { :controller => 'resets', :action => 'index', :protocol => 'https' } to /resets" do
      route_for(:controller => 'resets', :action => 'index', :protocol => 'https').should == '/resets'
    end

    it "should map { :controller => 'resets', :action => 'new', :protocol => 'https' } to /resets/new" do
      route_for(:controller => 'resets', :action => 'new', :protocol => 'https').should == '/resets/new'
    end

    it "should map { :controller => 'resets', :action => 'show', :id => 'foo', :protocol => 'https' } to /resets/foo" do
      route_for(:controller => 'resets', :action => 'show', :id => 'foo', :protocol => 'https').should == '/resets/foo'
    end

    it "should map { :controller => 'resets', :action => 'edit', :id => 'foo', :protocol => 'https' } to /resets/foo/edit" do
      route_for(:controller => 'resets', :action => 'edit', :id => 'foo', :protocol => 'https').should == '/resets/foo/edit'
    end

    it "should map { :controller => 'resets', :action => 'update', :id => 'foo', :protocol => 'https'} to /resets/foo" do
      route_for(:controller => 'resets', :action => 'update', :id => 'foo', :protocol => 'https').should == '/resets/foo'
    end

    it "should map { :controller => 'resets', :action => 'destroy', :id => 'foo', :protocol => 'https'} to /resets/foo" do
      route_for(:controller => 'resets', :action => 'destroy', :id => 'foo', :protocol => 'https').should == '/resets/foo'
    end
  end

  describe 'route recognition' do
    it "should generate params { :controller => 'resets', action => 'index', :protocol => 'https' } from GET /resets" do
      params_from(:get, '/resets').should == {:controller => 'resets', :action => 'index', :protocol => 'https'}
    end

    it "should generate params { :controller => 'resets', action => 'new', :protocol => 'https' } from GET /resets/new" do
      params_from(:get, '/resets/new').should == {:controller => 'resets', :action => 'new', :protocol => 'https'}
    end

    it "should generate params { :controller => 'resets', action => 'create', :protocol => 'https' } from POST /resets" do
      params_from(:post, '/resets').should == {:controller => 'resets', :action => 'create', :protocol => 'https'}
    end

    it "should generate params { :controller => 'resets', action => 'show', id => 'foo', :protocol => 'https' } from GET /resets/foo" do
      params_from(:get, '/resets/foo').should == {:controller => 'resets', :action => 'show', :id => 'foo', :protocol => 'https'}
    end

    it "should generate params { :controller => 'resets', action => 'edit', id => 'foo', :protocol => 'https' } from GET /resets/foo;edit" do
      params_from(:get, '/resets/foo/edit').should == {:controller => 'resets', :action => 'edit', :id => 'foo', :protocol => 'https'}
    end

    it "should generate params { :controller => 'resets', action => 'update', id => 'foo', :protocol => 'https' } from PUT /resets/foo" do
      params_from(:put, '/resets/foo').should == {:controller => 'resets', :action => 'update', :id => 'foo', :protocol => 'https'}
    end

    it "should generate params { :controller => 'resets', action => 'destroy', id => 'foo', :protocol => 'https' } from DELETE /resets/foo" do
      params_from(:delete, '/resets/foo').should == {:controller => 'resets', :action => 'destroy', :id => 'foo', :protocol => 'https'}
    end
  end
end
