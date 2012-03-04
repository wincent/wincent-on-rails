require 'spec_helper'

describe BlobsController do
  describe 'routing' do
    specify { get('/repos/wikitext/blobs/HEAD:Gemfile').should \
              map_to('blobs#show',
                     :repo_id => 'wikitext',
                     :id      => 'HEAD:Gemfile') }

    # no path
    specify { get('/repos/wikitext/blobs/master').should_not be_recognized }

    # no separator
    specify { get('/repos/wikitext/blobs/master:').should_not be_recognized }

    # multiple separators
    specify { get('/repos/wikitext/blobs/a:b:c').should_not be_recognized }
  end
end
