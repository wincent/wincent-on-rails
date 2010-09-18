require 'spec_helper'

describe ReposController do
  describe 'routing' do
    specify { get('/repos').should have_routing('repos#index') }
    specify { get('/repos/new').should have_routing('repos#new') }
    specify { post('/repos').should have_routing('repos#create') }
    specify { get('/repos/command-t').should have_routing('repos#show', :id => 'command-t') }
    specify { get('/repos/command-t/edit').should have_routing('repos#edit', :id => 'command-t') }
    specify { put('/repos/command-t').should have_routing('repos#update', :id => 'command-t') }
    specify { delete('/repos/command-t').should have_routing('repos#destroy', :id => 'command-t') }

    describe 'helpers' do
      let(:repo) { Repo.make! :permalink => 'foo' }

      describe 'repos_path' do
        specify { repos_path.should == '/repos' }
      end

      describe 'new_repo_path' do
        specify { new_repo_path.should == '/repos/new' }
      end

      describe 'repo_path' do
        specify { repo_path(repo).should == '/repos/foo' }
      end

      describe 'edit_repo_path' do
        specify { edit_repo_path(repo).should == '/repos/foo/edit' }
      end
    end
  end
end
