require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Admin::ForumsController do
  describe 'routing' do
    # NOTE: controller currently only implements #index, #show and #update
    specify { get('/admin/forums').should map('admin/forums#index') }
    specify { get('/admin/forums/new').should map('admin/forums#new') }
    specify { get('/admin/forums/foo').should map('admin/forums#show', :id => 'foo') }
    specify { get('/admin/forums/foo/edit').should map('admin/forums#edit', :id => 'foo') }
    specify { put('/admin/forums/foo').should map('admin/forums#update', :id => 'foo') }
    specify { delete('/admin/forums/foo').should map('admin/forums#destroy', :id => 'foo') }
    specify { post('/admin/forums').should map('admin/forums#create') }
  end
end
