require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe JsController do
  it_should_behave_like 'ApplicationController protected methods'

  describe '#show' do
    before do
      @namespace = nil
      @delegating_controller = 'issues'
      @delegated_action = 'edit'
    end

    def do_get
      delegated = [@delegating_controller, @delegated_action]
      delegated.unshift @namespace if @namespace
      pending 'spurious "No route matches" errors'
      # No route matches {:controller=>"js", :delegated=>"issues/edit.js", :action=>"show"}
      get :show, :delegated => delegated.join('/') + '.js'
    end

    it 'is successful' do
      do_get
      response.should be_success
    end

    it 'renders the "js/issues/show.js.erb" template' do
      do_get
      response.should render_template('js/issues/edit.js.erb')
    end

    it 'renders templates in the admin namespace' do
      @namespace = 'admin'
      do_get
      response.should render_template('js/admin/issues/edit.js.erb')
    end

    it 'does not use a layout' do
      do_get
      controller.active_layout.should be_nil
    end

    it 'does not page-cache the output' do
      do_not_allow(controller).cache_page
      do_get
    end
  end
end
