require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController, 'route generation' do
  it "should map { :controller => 'posts', :action => 'index', :protocol => 'https' } to /blog" do
    route_for(:controller => 'posts', :action => 'index', :protocol => 'https').should == '/blog'
  end

  it "should map { :controller => 'posts', :action => 'new', :protocol => 'https' } to /blog/new" do
    route_for(:controller => 'posts', :action => 'new', :protocol => 'https').should == '/blog/new'
  end

  it "should map { :controller => 'posts', :action => 'show', :id => '1', :protocol => 'https' } to /blog/1" do
    route_for(:controller => 'posts', :action => 'show', :id => '1', :protocol => 'https').should == '/blog/1'
  end

  it "should map { :controller => 'posts', :action => 'edit', :id => '1', :protocol => 'https' } to /blog/1/edit" do
    route_for(:controller => 'posts', :action => 'edit', :id => '1', :protocol => 'https').should == '/blog/1/edit'
  end

  it "should map { :controller => 'posts', :action => 'update', :id => '1', :protocol => 'https'} to /blog/1" do
    route_for(:controller => 'posts', :action => 'update', :id => '1', :protocol => 'https').should == { :path => '/blog/1', :method => 'put' }
  end

  it "should map { :controller => 'posts', :action => 'destroy', :id => 1, :protocol => 'https'} to /blog/1" do
    route_for(:controller => 'posts', :action => 'destroy', :id => '1', :protocol => 'https').should == { :path => '/blog/1', :method => 'delete' }
  end
end

describe PostsController, 'route recognition' do
  it "should generate params { :controller => 'posts', action => 'index', :protocol => 'https' } from GET /blog" do
    params_from(:get, '/blog').should == {:controller => 'posts', :action => 'index', :protocol => 'https'}
  end

  it "should generate params { :controller => 'posts', action => 'new', :protocol => 'https' } from GET /blog/new" do
    params_from(:get, '/blog/new').should == {:controller => 'posts', :action => 'new', :protocol => 'https'}
  end

  it "should generate params { :controller => 'posts', action => 'create', :protocol => 'https' } from POST /blog" do
    params_from(:post, '/blog').should == {:controller => 'posts', :action => 'create', :protocol => 'https'}
  end

  it "should generate params { :controller => 'posts', action => 'show', id => '1', :protocol => 'https' } from GET /blog/1" do
    params_from(:get, '/blog/1').should == {:controller => 'posts', :action => 'show', :id => '1', :protocol => 'https'}
  end

  it "should generate params { :controller => 'posts', action => 'edit', id => '1', :protocol => 'https' } from GET /blog/1;edit" do
    params_from(:get, '/blog/1/edit').should == {:controller => 'posts', :action => 'edit', :id => '1', :protocol => 'https'}
  end

  it "should generate params { :controller => 'posts', action => 'update', id => '1', :protocol => 'https' } from PUT /blog/1" do
    params_from(:put, '/blog/1').should == {:controller => 'posts', :action => 'update', :id => '1', :protocol => 'https'}
  end

  it "should generate params { :controller => 'posts', action => 'destroy', id => '1', :protocol => 'https' } from DELETE /blog/1" do
    params_from(:delete, '/blog/1').should == {:controller => 'posts', :action => 'destroy', :id => '1', :protocol => 'https'}
  end
end
