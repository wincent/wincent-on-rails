require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe JsController do
  describe 'routing' do
    specify { get('/js/issues/show.js').should map_to('js#show', :delegated => 'issues/show.js') }
    specify { get('/js/admin/issues/edit.js').should map_to('js#show', :delegated => 'admin/issues/edit.js') }

    # numbers in :delegated param
    specify { get('/js/99999/edit.js').should_not be_recognized }

    # missing .js extension
    specify { get('/js/issues/edit').should_not be_recognized }

    # missing either action or controller
    specify { get('/js/issues.js').should_not be_recognized }

    # maliciously formatted params
    specify { get('/js/../../../../etc/passwd').should_not be_recognized }
  end
end
