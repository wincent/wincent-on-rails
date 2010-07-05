require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe LinksController do
  describe 'routing' do
    specify { get('/links').should map('links#index') }
    specify { get('/links/new').should map('links#new') }
    specify { get('/links/foo').should map('links#show', :id => 'foo') }
    specify { get('/links/foo/edit').should map('links#edit', :id => 'foo') }
    specify { put('/links/foo').should map('links#update', :id => 'foo') }
    specify { delete('/links/foo').should map('links#destroy', :id => 'foo') }
    specify { post('/links').should map('links#create') }

    # shortcut
    specify { get('l/foo').should map_to('links#show', :id => 'foo') }

    describe 'helpers' do
      before do
        @link = Link.stub :permalink => 'foo'
      end

      describe 'links_path' do
        specify { links_path.should == '/links' }
      end

      describe 'new_link_path' do
        specify { new_link_path.should == '/links/new' }
      end

      describe 'link_path' do
        specify { link_path(@link).should == '/links/foo' }
      end

      describe 'edit_link_path' do
        specify { edit_link_path(@link).should == '/links/foo/edit' }
      end

      describe 'edit_link_path' do
        specify { edit_link_path(@link).should == '/links/foo/edit' }
      end
    end
  end
end
