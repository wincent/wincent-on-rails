require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JsController do
  describe 'route generation' do
    it 'maps #show' do
      route_for(:controller => 'js',
                :action => 'show',
                :delegated => 'issues/edit',
                :protocol => 'https').should == '/js/issues/edit'
    end

    it 'maps #show inside admin namespace' do
      route_for(:controller => 'js',
                :action => 'show',
                :delegated => 'admin/issues/edit',
                :protocol => 'https').should == '/js/admin/issues/edit'
    end
  end

  describe 'route recognition' do
    it 'generates params for #show' do
      params_from(:get, '/js/issues/edit').should == {
        :controller => 'js',
        :action => 'show',
        :delegated => 'issues/edit',
        :protocol => 'https'
      }
    end

    it 'generates params for #show inside admin namespace' do
      params_from(:get, '/js/admin/issues/edit').should == {
        :controller => 'js',
        :action => 'show',
        :delegated => 'admin/issues/edit',
        :protocol => 'https'
      }
    end
  end
end
