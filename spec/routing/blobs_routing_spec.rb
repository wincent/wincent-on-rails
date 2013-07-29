require 'spec_helper'

describe BlobsController do
  describe 'routing' do
    specify do
      expect(get: '/repos/wikitext/blobs/HEAD:Gemfile').
        to route_to('blobs#show', repo_id: 'wikitext', id: 'HEAD:Gemfile')
    end

    # no path
    specify { expect(get: '/repos/wikitext/blobs/master').to_not be_routable }

    # separator but not path
    specify { expect(get: '/repos/wikitext/blobs/master:').to_not be_routable }

    # multiple separators
    specify { expect(get: '/repos/wikitext/blobs/a:b:c').to_not be_routable }
  end
end
