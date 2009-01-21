require File.dirname(__FILE__) + '/../spec_helper'

describe ArticlesController do
  describe 'route generation' do
    it "should map { :controller => 'articles', :action => 'index', :protocol => 'https' } to /wiki" do
      route_for(:controller => "articles", :action => "index", :protocol => 'https').should == "/wiki"
    end

    it "should map { :controller => 'articles', :action => 'new', :protocol => 'https' } to /wiki/new" do
      route_for(:controller => "articles", :action => "new", :protocol => 'https').should == "/wiki/new"
    end

    it "should map { :controller => 'articles', :action => 'show', :id => 'foo', :protocol => 'https' } to /wiki/foo" do
      route_for(:controller => "articles", :action => "show", :id => 'foo', :protocol => 'https').should == "/wiki/foo"
    end

    it "should map { :controller => 'articles', :action => 'edit', :id => 'foo', :protocol => 'https' } to /wiki/foo/edit" do
      route_for(:controller => "articles", :action => "edit", :id => 'foo', :protocol => 'https').should == "/wiki/foo/edit"
    end

    it "should map { :controller => 'articles', :action => 'update', :id => 'foo', :protocol => 'https' } to /wiki/foo" do
      route_for(:controller => "articles", :action => "update", :id => 'foo', :protocol => 'https').should == "/wiki/foo"
    end

    it "should map { :controller => 'articles', :action => 'destroy', :id => 'foo', :protocol => 'https' } to /wiki/foo" do
      route_for(:controller => "articles", :action => "destroy", :id => 'foo', :protocol => 'https').should == "/wiki/foo"
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'articles', action => 'index', :protocol => 'https' } from GET /wiki" do
      params_from(:get, "/wiki").should == {:controller => "articles", :action => "index", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', action => 'new', :protocol => 'https' } from GET /wiki/new" do
      params_from(:get, "/wiki/new").should == {:controller => "articles", :action => "new", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', action => 'create', :protocol => 'https' } from POST /wiki" do
      params_from(:post, "/wiki").should == {:controller => "articles", :action => "create", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', action => 'show', id => 'foo', :protocol => 'https' } from GET /wiki/foo" do
      params_from(:get, "/wiki/foo").should == {:controller => "articles", :action => "show", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', action => 'edit', id => 'foo', :protocol => 'https' } from GET /wiki/foo;edit" do
      params_from(:get, "/wiki/foo/edit").should == {:controller => "articles", :action => "edit", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', action => 'update', id => 'foo', :protocol => 'https' } from PUT /wiki/foo" do
      params_from(:put, "/wiki/foo").should == {:controller => "articles", :action => "update", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', action => 'destroy', id => 'foo', :protocol => 'https' } from DELETE /wiki/foo" do
      params_from(:delete, "/wiki/foo").should == {:controller => "articles", :action => "destroy", :id => "foo", :protocol => 'https'}
    end
  end
end
