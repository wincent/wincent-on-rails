require 'spec_helper'

describe JsController do
  describe 'routing' do
    specify { expect(get: '/js/issues/show.js').to route_to('js#show', delegated: 'issues/show.js') }
    specify { expect(get: '/js/admin/issues/edit.js').to route_to('js#show', delegated: 'admin/issues/edit.js') }

    # numbers in :delegated param
    specify { expect(get: '/js/99999/edit.js').to_not be_routable }

    # missing .js extension
    specify { expect(get: '/js/issues/edit').to_not be_routable }

    # missing either action or controller
    specify { expect(get: '/js/issues.js').to_not be_routable }

    # maliciously formatted params
    specify { expect(get: '/js/../../../../etc/passwd').to_not be_routable }
  end
end
