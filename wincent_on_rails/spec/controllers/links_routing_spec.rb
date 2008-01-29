require File.dirname(__FILE__) + '/../spec_helper'

describe LinksController do
  describe "route generation" do

    it "should map { :controller => 'links', :action => 'index' } to /links" do
      route_for(:controller => "links", :action => "index").should == "/links"
    end
  
    it "should map { :controller => 'links', :action => 'new' } to /links/new" do
      route_for(:controller => "links", :action => "new").should == "/links/new"
    end
  
    it "should map { :controller => 'links', :action => 'show', :id => 1 } to /links/1" do
      route_for(:controller => "links", :action => "show", :id => 1).should == "/links/1"
    end
  
    it "should map { :controller => 'links', :action => 'edit', :id => 1 } to /links/1/edit" do
      route_for(:controller => "links", :action => "edit", :id => 1).should == "/links/1/edit"
    end
  
    it "should map { :controller => 'links', :action => 'update', :id => 1} to /links/1" do
      route_for(:controller => "links", :action => "update", :id => 1).should == "/links/1"
    end
  
    it "should map { :controller => 'links', :action => 'destroy', :id => 1} to /links/1" do
      route_for(:controller => "links", :action => "destroy", :id => 1).should == "/links/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'links', action => 'index' } from GET /links" do
      params_from(:get, "/links").should == {:controller => "links", :action => "index"}
    end
  
    it "should generate params { :controller => 'links', action => 'new' } from GET /links/new" do
      params_from(:get, "/links/new").should == {:controller => "links", :action => "new"}
    end
  
    it "should generate params { :controller => 'links', action => 'create' } from POST /links" do
      params_from(:post, "/links").should == {:controller => "links", :action => "create"}
    end
  
    it "should generate params { :controller => 'links', action => 'show', id => '1' } from GET /links/1" do
      params_from(:get, "/links/1").should == {:controller => "links", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'links', action => 'edit', id => '1' } from GET /links/1;edit" do
      params_from(:get, "/links/1/edit").should == {:controller => "links", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'links', action => 'update', id => '1' } from PUT /links/1" do
      params_from(:put, "/links/1").should == {:controller => "links", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'links', action => 'destroy', id => '1' } from DELETE /links/1" do
      params_from(:delete, "/links/1").should == {:controller => "links", :action => "destroy", :id => "1"}
    end
  end
end