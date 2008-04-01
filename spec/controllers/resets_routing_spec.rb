require File.dirname(__FILE__) + '/../spec_helper'

describe ResetsController do
  describe 'route generation' do
    it "should map { :controller => 'resets', :action => 'index' } to /resets" do
      route_for(:controller => 'resets', :action => 'index').should == '/resets'
    end

    it "should map { :controller => 'resets', :action => 'new' } to /resets/new" do
      route_for(:controller => 'resets', :action => 'new').should == '/resets/new'
    end

    it "should map { :controller => 'resets', :action => 'show', :id => 'foo' } to /resets/foo" do
      route_for(:controller => 'resets', :action => 'show', :id => 'foo').should == '/resets/foo'
    end

    it "should map { :controller => 'resets', :action => 'edit', :id => 'foo' } to /resets/foo/edit" do
      route_for(:controller => 'resets', :action => 'edit', :id => 'foo').should == '/resets/foo/edit'
    end

    it "should map { :controller => 'resets', :action => 'update', :id => 'foo'} to /resets/foo" do
      route_for(:controller => 'resets', :action => 'update', :id => 'foo').should == '/resets/foo'
    end

    it "should map { :controller => 'resets', :action => 'destroy', :id => 'foo'} to /resets/foo" do
      route_for(:controller => 'resets', :action => 'destroy', :id => 'foo').should == '/resets/foo'
    end
  end

  describe 'route recognition' do
    it "should generate params { :controller => 'resets', action => 'index' } from GET /resets" do
      params_from(:get, '/resets').should == {:controller => 'resets', :action => 'index'}
    end

    it "should generate params { :controller => 'resets', action => 'new' } from GET /resets/new" do
      params_from(:get, '/resets/new').should == {:controller => 'resets', :action => 'new'}
    end

    it "should generate params { :controller => 'resets', action => 'create' } from POST /resets" do
      params_from(:post, '/resets').should == {:controller => 'resets', :action => 'create'}
    end

    it "should generate params { :controller => 'resets', action => 'show', id => 'foo' } from GET /resets/foo" do
      params_from(:get, '/resets/foo').should == {:controller => 'resets', :action => 'show', :id => 'foo'}
    end

    it "should generate params { :controller => 'resets', action => 'edit', id => 'foo' } from GET /resets/foo;edit" do
      params_from(:get, '/resets/foo/edit').should == {:controller => 'resets', :action => 'edit', :id => 'foo'}
    end

    it "should generate params { :controller => 'resets', action => 'update', id => 'foo' } from PUT /resets/foo" do
      params_from(:put, '/resets/foo').should == {:controller => 'resets', :action => 'update', :id => 'foo'}
    end

    it "should generate params { :controller => 'resets', action => 'destroy', id => 'foo' } from DELETE /resets/foo" do
      params_from(:delete, '/resets/foo').should == {:controller => 'resets', :action => 'destroy', :id => 'foo'}
    end
  end
end