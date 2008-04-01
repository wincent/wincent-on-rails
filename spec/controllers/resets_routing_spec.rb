require File.dirname(__FILE__) + '/../spec_helper'

describe ResetsController do
  describe "route generation" do

    it "should map { :controller => 'resets', :action => 'index' } to /resets" do
      route_for(:controller => "resets", :action => "index").should == "/resets"
    end
  
    it "should map { :controller => 'resets', :action => 'new' } to /resets/new" do
      route_for(:controller => "resets", :action => "new").should == "/resets/new"
    end
  
    it "should map { :controller => 'resets', :action => 'show', :id => 1 } to /resets/1" do
      route_for(:controller => "resets", :action => "show", :id => 1).should == "/resets/1"
    end
  
    it "should map { :controller => 'resets', :action => 'edit', :id => 1 } to /resets/1/edit" do
      route_for(:controller => "resets", :action => "edit", :id => 1).should == "/resets/1/edit"
    end
  
    it "should map { :controller => 'resets', :action => 'update', :id => 1} to /resets/1" do
      route_for(:controller => "resets", :action => "update", :id => 1).should == "/resets/1"
    end
  
    it "should map { :controller => 'resets', :action => 'destroy', :id => 1} to /resets/1" do
      route_for(:controller => "resets", :action => "destroy", :id => 1).should == "/resets/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'resets', action => 'index' } from GET /resets" do
      params_from(:get, "/resets").should == {:controller => "resets", :action => "index"}
    end
  
    it "should generate params { :controller => 'resets', action => 'new' } from GET /resets/new" do
      params_from(:get, "/resets/new").should == {:controller => "resets", :action => "new"}
    end
  
    it "should generate params { :controller => 'resets', action => 'create' } from POST /resets" do
      params_from(:post, "/resets").should == {:controller => "resets", :action => "create"}
    end
  
    it "should generate params { :controller => 'resets', action => 'show', id => '1' } from GET /resets/1" do
      params_from(:get, "/resets/1").should == {:controller => "resets", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'resets', action => 'edit', id => '1' } from GET /resets/1;edit" do
      params_from(:get, "/resets/1/edit").should == {:controller => "resets", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'resets', action => 'update', id => '1' } from PUT /resets/1" do
      params_from(:put, "/resets/1").should == {:controller => "resets", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'resets', action => 'destroy', id => '1' } from DELETE /resets/1" do
      params_from(:delete, "/resets/1").should == {:controller => "resets", :action => "destroy", :id => "1"}
    end
  end
end