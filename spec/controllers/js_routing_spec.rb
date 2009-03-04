require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JsController do
  describe 'route generation' do
    it 'maps #show' do
      route_for(:controller => 'js',
                :action => 'show',
                :delegating_controller => 'issues',
                :delegated_action => 'edit',
                :protocol => 'https').should == '/js/issues/edit'
    end
  end

  describe 'route recognition' do
    it 'generates params for #show' do
      params_from(:get, '/js/issues/edit').should == {
        :controller => 'js',
        :action => 'show',
        :delegating_controller => 'issues',
        :delegated_action => 'edit',
        :protocol => 'https'
      }
    end
  end
end
