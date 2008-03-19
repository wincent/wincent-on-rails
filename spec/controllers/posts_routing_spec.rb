require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController, 'route generation' do
  it "should map { :controller => 'posts', :action => 'index' } to /blog" do
    route_for(:controller => 'posts', :action => 'index').should == '/blog'
  end

  it "should map { :controller => 'posts', :action => 'new' } to /blog/new" do
    route_for(:controller => 'posts', :action => 'new').should == '/blog/new'
  end

  it "should map { :controller => 'posts', :action => 'show', :id => 1 } to /blog/1" do
    route_for(:controller => 'posts', :action => 'show', :id => 1).should == '/blog/1'
  end

  it "should map { :controller => 'posts', :action => 'edit', :id => 1 } to /blog/1/edit" do
    route_for(:controller => 'posts', :action => 'edit', :id => 1).should == '/blog/1/edit'
  end

  it "should map { :controller => 'posts', :action => 'update', :id => 1} to /blog/1" do
    route_for(:controller => 'posts', :action => 'update', :id => 1).should == '/blog/1'
  end

  it "should map { :controller => 'posts', :action => 'destroy', :id => 1} to /blog/1" do
    route_for(:controller => 'posts', :action => 'destroy', :id => 1).should == '/blog/1'
  end
end

describe PostsController, 'route recognition' do
  it "should generate params { :controller => 'posts', action => 'index' } from GET /blog" do
    params_from(:get, '/blog').should == {:controller => 'posts', :action => 'index'}
  end

  it "should generate params { :controller => 'posts', action => 'new' } from GET /blog/new" do
    params_from(:get, '/blog/new').should == {:controller => 'posts', :action => 'new'}
  end

  it "should generate params { :controller => 'posts', action => 'create' } from POST /blog" do
    params_from(:post, '/blog').should == {:controller => 'posts', :action => 'create'}
  end

  it "should generate params { :controller => 'posts', action => 'show', id => '1' } from GET /blog/1" do
    params_from(:get, '/blog/1').should == {:controller => 'posts', :action => 'show', :id => '1'}
  end

  it "should generate params { :controller => 'posts', action => 'edit', id => '1' } from GET /blog/1;edit" do
    params_from(:get, '/blog/1/edit').should == {:controller => 'posts', :action => 'edit', :id => '1'}
  end

  it "should generate params { :controller => 'posts', action => 'update', id => '1' } from PUT /blog/1" do
    params_from(:put, '/blog/1').should == {:controller => 'posts', :action => 'update', :id => '1'}
  end

  it "should generate params { :controller => 'posts', action => 'destroy', id => '1' } from DELETE /blog/1" do
    params_from(:delete, '/blog/1').should == {:controller => 'posts', :action => 'destroy', :id => '1'}
  end
end
