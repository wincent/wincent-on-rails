require File.dirname(__FILE__) + '/../spec_helper'

describe ArticlesController do
  describe 'route generation' do

    it "should map { :controller => 'articles', :action => 'index' } to /wiki" do
      route_for(:controller => "articles", :action => "index").should == "/wiki"
    end

    it "should map { :controller => 'articles', :action => 'new' } to /wiki/new" do
      route_for(:controller => "articles", :action => "new").should == "/wiki/new"
    end

    it "should map { :controller => 'articles', :action => 'show', :id => 'foo' } to /wiki/foo" do
      route_for(:controller => "articles", :action => "show", :id => 'foo').should == "/wiki/foo"
    end

    it "should map { :controller => 'articles', :action => 'edit', :id => 'foo' } to /wiki/foo/edit" do
      route_for(:controller => "articles", :action => "edit", :id => 'foo').should == "/wiki/foo/edit"
    end

    it "should map { :controller => 'articles', :action => 'update', :id => 'foo'} to /wiki/foo" do
      route_for(:controller => "articles", :action => "update", :id => 'foo').should == "/wiki/foo"
    end

    it "should map { :controller => 'articles', :action => 'destroy', :id => 'foo'} to /wiki/foo" do
      route_for(:controller => "articles", :action => "destroy", :id => 'foo').should == "/wiki/foo"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'articles', action => 'index' } from GET /wiki" do
      params_from(:get, "/wiki").should == {:controller => "articles", :action => "index"}
    end

    it "should generate params { :controller => 'articles', action => 'new' } from GET /wiki/new" do
      params_from(:get, "/wiki/new").should == {:controller => "articles", :action => "new"}
    end

    it "should generate params { :controller => 'articles', action => 'create' } from POST /wiki" do
      params_from(:post, "/wiki").should == {:controller => "articles", :action => "create"}
    end

    it "should generate params { :controller => 'articles', action => 'show', id => 'foo' } from GET /wiki/foo" do
      params_from(:get, "/wiki/foo").should == {:controller => "articles", :action => "show", :id => "foo"}
    end

    it "should generate params { :controller => 'articles', action => 'edit', id => 'foo' } from GET /wiki/foo;edit" do
      params_from(:get, "/wiki/foo/edit").should == {:controller => "articles", :action => "edit", :id => "foo"}
    end

    it "should generate params { :controller => 'articles', action => 'update', id => 'foo' } from PUT /wiki/foo" do
      params_from(:put, "/wiki/foo").should == {:controller => "articles", :action => "update", :id => "foo"}
    end

    it "should generate params { :controller => 'articles', action => 'destroy', id => 'foo' } from DELETE /wiki/foo" do
      params_from(:delete, "/wiki/foo").should == {:controller => "articles", :action => "destroy", :id => "foo"}
    end
  end
end
