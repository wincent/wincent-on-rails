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
      pending 'model and factory'
    end
  end
end
