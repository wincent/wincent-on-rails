require File.dirname(__FILE__) + '/../spec_helper'

describe LinksController do
  describe "route generation" do
    it "should map { :controller => 'links', :action => 'index', :protocol => 'https' } to /links" do
      route_for(:controller => "links", :action => "index", :protocol => 'https').should == "/links"
    end

    it "should map { :controller => 'links', :action => 'new', :protocol => 'https' } to /links/new" do
      route_for(:controller => "links", :action => "new", :protocol => 'https').should == "/links/new"
    end

    it "should map { :controller => 'links', :action => 'show', :id => '1', :protocol => 'https' } to /links/1" do
      route_for(:controller => "links", :action => "show", :id => '1', :protocol => 'https').should == "/links/1"
    end

    it "should map { :controller => 'links', :action => 'edit', :id => '1', :protocol => 'https' } to /links/1/edit" do
      route_for(:controller => "links", :action => "edit", :id => '1', :protocol => 'https').should == "/links/1/edit"
    end

    it "should map { :controller => 'links', :action => 'update', :id => '1', :protocol => 'https'} to /links/1" do
      route_for(:controller => "links", :action => "update", :id => '1', :protocol => 'https').should == { :path => '/links/1', :method => 'put' }
    end

    it "should map { :controller => 'links', :action => 'destroy', :id => '1', :protocol => 'https'} to /links/1" do
      route_for(:controller => "links", :action => "destroy", :id => '1', :protocol => 'https').should == { :path => '/links/1', :method => 'delete' }
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'links', action => 'index', :protocol => 'https' } from GET /links" do
      params_from(:get, "/links").should == {:controller => "links", :action => "index", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'new', :protocol => 'https' } from GET /links/new" do
      params_from(:get, "/links/new").should == {:controller => "links", :action => "new", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'create', :protocol => 'https' } from POST /links" do
      params_from(:post, "/links").should == {:controller => "links", :action => "create", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'show', id => '1', :protocol => 'https' } from GET /links/1" do
      params_from(:get, "/links/1").should == {:controller => "links", :action => "show", :id => "1", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'show', id => 'foo', :protocol => 'https' } from GET /links/foo (permalink)" do
      params_from(:get, "/links/foo").should == {:controller => "links", :action => "show", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'show', id => '1', :protocol => 'https' } from GET /l/1 (shortcut)" do
      params_from(:get, "/l/1").should == {:controller => "links", :action => "show", :id => "1", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'show', id => 'foo', :protocol => 'https' } from GET /l/foo (shortcut, permalink)" do
      params_from(:get, "/l/foo").should == {:controller => "links", :action => "show", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'edit', id => '1', :protocol => 'https' } from GET /links/1/edit" do
      params_from(:get, "/links/1/edit").should == {:controller => "links", :action => "edit", :id => "1", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'update', id => '1', :protocol => 'https' } from PUT /links/1" do
      params_from(:put, "/links/1").should == {:controller => "links", :action => "update", :id => "1", :protocol => 'https'}
    end

    it "should generate params { :controller => 'links', action => 'destroy', id => '1', :protocol => 'https' } from DELETE /links/1" do
      params_from(:delete, "/links/1").should == {:controller => "links", :action => "destroy", :id => "1", :protocol => 'https'}
    end
  end
end
