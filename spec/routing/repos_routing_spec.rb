require 'spec_helper'

describe ReposController do
  describe 'routing' do
    specify { expect(get: '/repos').to route_to('repos#index') }
    specify { expect(get: '/repos/new').to route_to('repos#new') }
    specify { expect(post: '/repos').to route_to('repos#create') }
    specify { expect(get: '/repos/command-t').to route_to('repos#show', id: 'command-t') }
    specify { expect(get: '/repos/command-t/edit').to route_to('repos#edit', id: 'command-t') }
    specify { expect(put: '/repos/command-t').to route_to('repos#update', id: 'command-t') }
    specify { expect(delete: '/repos/command-t').to route_to('repos#destroy', id: 'command-t') }

    describe 'helpers' do
      let(:repo) { Repo.make! permalink: 'foo' }

      describe 'repos_path' do
        specify { expect(repos_path).to eq('/repos') }
      end

      describe 'new_repo_path' do
        specify { expect(new_repo_path).to eq('/repos/new') }
      end

      describe 'repo_path' do
        specify { expect(repo_path(repo)).to eq('/repos/foo') }
      end

      describe 'edit_repo_path' do
        specify { expect(edit_repo_path(repo)).to eq('/repos/foo/edit') }
      end
    end
  end
end
