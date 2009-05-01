require File.dirname(__FILE__) + '/../spec_helper'

describe TagsController do
  describe 'route generation' do
    it "should map { controller: 'tags', action: 'index', protocol: 'https' } to /tags" do
      route_for(:controller => "tags", :action => "index", :protocol => 'https').should == "/tags"
    end

    it "should map { controller: 'tags', action: 'new', protocol: 'https' } to /tags/new" do
      route_for(:controller => "tags", :action => "new", :protocol => 'https').should == "/tags/new"
    end

    it "should map { controller: 'tags', action: 'show', id: 'foo', protocol: 'https' } to /tags/foo" do
      route_for(:controller => "tags", :action => "show", :id => 'foo', :protocol => 'https').should == "/tags/foo"
    end

    # tag name including period
    it "should map { controller: 'tags', action: 'show', id: 'foo.bar', protocol: 'https' } to /tags/foo.bar" do
      route_for(:controller => "tags", :action => "show", :id => 'foo.bar', :protocol => 'https').should == "/tags/foo.bar"
    end

    # tag name including number
    it "should map { controller: 'tags', action: 'show', id: 'wopen3', protocol: 'https' } to /tags/wopen3" do
      route_for(:controller => "tags", :action => "show", :id => 'wopen3', :protocol => 'https').should == "/tags/wopen3"
    end

    it "should map { controller: 'tags', action: 'edit', id: 'foo', protocol: 'https' } to /tags/foo/edit" do
      route_for(:controller => "tags", :action => "edit", :id => 'foo', :protocol => 'https').should == "/tags/foo/edit"
    end

    it "should map { controller: 'tags', action: 'update', id: 'foo', protocol: 'https' } to /tags/foo" do
      route_for(:controller => "tags", :action => "update", :id => 'foo', :protocol => 'https').should == { :path => '/tags/foo', :method => 'put' }
    end

    it "should map { controller: 'tags', action: 'destroy', id: 'foo', protocol: 'https' } to /tags/foo" do
      route_for(:controller => "tags", :action => "destroy", :id => 'foo', :protocol => 'https').should == { :path => '/tags/foo', :method => 'delete' }
    end
  end

  describe "route recognition" do
    it "should generate params { controller: 'tags', action: 'index', protocol: 'https' } from GET /tags" do
      params_from(:get, "/tags").should == {:controller => "tags", :action => "index", :protocol => 'https'}
    end

    it "should generate params { controller: 'tags', action: 'new', protocol: 'https' } from GET /tags/new" do
      params_from(:get, "/tags/new").should == {:controller => "tags", :action => "new", :protocol => 'https'}
    end

    it "should generate params { controller: 'tags', action: 'create', protocol: 'https' } from POST /tags" do
      params_from(:post, "/tags").should == {:controller => "tags", :action => "create", :protocol => 'https'}
    end

    it "should generate params { controller: 'tags', action: 'show', id: 'foo', protocol: 'https' } from GET /tags/foo" do
      params_from(:get, "/tags/foo").should == {:controller => "tags", :action => "show", :id => "foo", :protocol => 'https'}
    end

    # tag name including period
    it "should generate params { controller: 'tags', action: 'show', id: 'foo.bar', protocol: 'https' } from GET /tags/foo.bar" do
      params_from(:get, "/tags/foo.bar").should == {:controller => "tags", :action => "show", :id => "foo.bar", :protocol => 'https'}
    end

    # tag name including number
    it "should generate params { controller: 'tags', action: 'show', id: 'wopen3', protocol: 'https' } from GET /tags/wopen3" do
      params_from(:get, "/tags/wopen3").should == {:controller => "tags", :action => "show", :id => "wopen3", :protocol => 'https'}
    end

    it "should generate params { controller: 'tags', action: 'edit', id: 'foo', protocol: 'https' } from GET /tags/foo/edit" do
      params_from(:get, "/tags/foo/edit").should == {:controller => "tags", :action => "edit", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { controller: 'tags', action: 'update', id: 'foo', protocol: 'https' } from PUT /tags/foo" do
      params_from(:put, "/tags/foo").should == {:controller => "tags", :action => "update", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { controller: 'tags', action: 'destroy', id: 'foo', protocol: 'https' } from DELETE /tags/foo" do
      params_from(:delete, "/tags/foo").should == {:controller => "tags", :action => "destroy", :id => "foo", :protocol => 'https'}
    end
  end
end
