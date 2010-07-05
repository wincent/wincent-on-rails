require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe JsController do
  describe 'routing' do
    specify { get('/js/issues/show.js').should map_to('js#show', :delegated => 'issues/show.js') }
    specify { get('/js/admin/issues/edit.js').should map_to('js#show', :delegated => 'admin/issues/edit.js') }
  end
end
