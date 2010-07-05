require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe LinksController do
  describe 'routing' do
    it { get('/links').should map('links#index') }
    it { get('/links/new').should map('links#new') }
    it { get('/links/foo').should map('links#show', :id => 'foo') }
    it { get('/links/foo/edit').should map('links#edit', :id => 'foo') }
    it { put('/links/foo').should map('links#update', :id => 'foo') }
    it { delete('/links/foo').should map('links#destroy', :id => 'foo') }
    it { post('/links').should map('links#create') }

    # shortcut
    it { get('l/foo').should map_to('links#show', :id => 'foo') }

    describe 'helpers' do
      before do
        @link = Link.stub :permalink => 'foo'
      end

      describe 'links_path' do
        it { links_path.should == '/links' }
      end

      describe 'new_link_path' do
        it { new_link_path.should == '/links/new' }
      end

      describe 'link_path' do
        it { link_path(@link).should == '/links/foo' }
      end

      describe 'edit_link_path' do
        it { edit_link_path(@link).should == '/links/foo/edit' }
      end

      describe 'edit_link_path' do
        it { edit_link_path(@link).should == '/links/foo/edit' }
      end
    end
  end
end
