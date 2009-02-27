require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TweetsController do
  describe 'route generation' do
    it 'maps #index' do
      route_for(:controller => 'tweets', :action => 'index', :protocol => 'https').should == '/twitter'
    end

    it 'maps #new' do
      route_for(:controller => 'tweets', :action => 'new', :protocol => 'https').should == '/twitter/new'
    end

    it 'maps #show' do
      route_for(:controller => 'tweets', :action => 'show', :id => '1', :protocol => 'https').should == '/twitter/1'
    end

    it 'maps #edit' do
      route_for(:controller => 'tweets', :action => 'edit', :id => '1', :protocol => 'https').should == '/twitter/1/edit'
    end

    it 'maps #create' do
      route_for(:controller => 'tweets', :action => 'create', :protocol => 'https').should == { :path => '/twitter', :method => :post }
    end

    it 'maps #update' do
      route_for(:controller => 'tweets', :action => 'update', :id => '1', :protocol => 'https').should == { :path =>'/twitter/1', :method => :put }
    end

    it 'maps #destroy' do
      route_for(:controller => 'tweets', :action => 'destroy', :id => '1', :protocol => 'https').should == { :path =>'/twitter/1', :method => :delete }
    end

    it 'maps #index/page/:page' do
      route_for(:controller => 'tweets', :action => 'index', :page => '2', :protocol => 'https').should == '/twitter/page/2'
    end
  end

  describe 'route recognition' do
    it 'generates params for #index' do
      params_from(:get, '/twitter').should == { :controller => 'tweets', :action => 'index', :protocol => 'https' }
    end

    it 'generates params for #new' do
      params_from(:get, '/twitter/new').should == { :controller => 'tweets', :action => 'new', :protocol => 'https' }
    end

    it 'generates params for #create' do
      params_from(:post, '/twitter').should == { :controller => 'tweets', :action => 'create', :protocol => 'https' }
    end

    it 'generates params for #show' do
      params_from(:get, '/twitter/1').should == { :controller => 'tweets', :action => 'show', :id => '1', :protocol => 'https' }
    end

    it 'generates params for #edit' do
      params_from(:get, '/twitter/1/edit').should == { :controller => 'tweets', :action => 'edit', :id => '1', :protocol => 'https' }
    end

    it 'generates params for #update' do
      params_from(:put, '/twitter/1').should == { :controller => 'tweets', :action => 'update', :id => '1', :protocol => 'https' }
    end

    it 'generates params for #destroy' do
      params_from(:delete, '/twitter/1').should == { :controller => 'tweets', :action => 'destroy', :id => '1', :protocol => 'https' }
    end

    it 'generates params for #index/page/:page' do
      params_from(:get, '/twitter/page/2').should == { :controller => 'tweets', :action => 'index', :page => '2', :protocol => 'https' }
    end
  end
end
