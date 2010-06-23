require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe JsController do
  describe 'routing' do
    it 'maps #show' do
      pending 'due to RSpec 1.2.9 breakage'
      # see: https://rspec.lighthouseapp.com/projects/5645/tickets/907
      { :get => '/js/issues/show' }.should \
        route_to( :controller => 'js',
                  :action => 'show',
                  :delegated => 'issues/show',
                  :protocol => 'https')
    end

    it 'maps #show inside admin namespace' do
      pending 'due to RSpec 1.2.9 breakage'
      # see: https://rspec.lighthouseapp.com/projects/5645/tickets/907
      { :get => '/js/admin/issues/edit' }.should \
        route_to( :controller => 'js',
                  :action => 'show',
                  :delegated => 'admin/issues/edit',
                  :protocol => 'https')
    end
  end
end
