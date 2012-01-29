require 'spec_helper'

describe SnippetsController do
  describe 'routing' do
    specify do
      get('/snippets').should have_routing('snippets#index')
    end

    specify do
      get('/snippets/new').should have_routing('snippets#new')
    end

    specify do
      get('/snippets/123').should have_routing('snippets#show', :id => '123')
    end

    specify do
      get('/snippets/123/edit').
        should have_routing('snippets#edit', :id => '123')
    end

    specify do
      put('/snippets/123').should have_routing('snippets#update', :id => '123')
    end

    specify do
      delete('/snippets/123').
        should have_routing('snippets#destroy', :id => '123')
    end

    specify do
      post('/snippets').should have_routing('snippets#create')
    end

    describe 'index pagination' do
      specify do
        get('/snippets/page/2').
          should have_routing('snippets#index', :page => '2')
      end

      it 'rejects non-numeric :page params' do
        get('/snippets/page/foo').should_not be_recognized
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify do
        get('/snippets/123/comments/new').
          should have_routing('comments#new', :snippet_id => '123')
      end

      specify do
        post('/snippets/123/comments').
          should have_routing('comments#create', :snippet_id => '123')
      end

      specify do
        put('/snippets/123/comments/456').
          should have_routing('comments#update', :snippet_id => '123', :id => '456')
      end

      # all other RESTful actions are no-ops
      specify do
        get('/snippets/123/comments').should_not be_recognized
      end

      specify do
        get('/snippets/123/comments/456').should_not be_recognized
      end

      specify do
        get('/snippets/123/comments/456/edit').should_not be_recognized
      end

      specify do
        delete('/snippets/123/comments/456').should_not be_recognized
      end
    end

    describe 'helpers' do
      before do
        @snippet = Snippet.stub
      end

      describe 'snippets_path' do
        specify { snippets_path.should == '/snippets' }
      end

      describe 'new_snippet_path' do
        specify { new_snippet_path.should == '/snippets/new' }
      end

      describe 'snippet_path' do
        specify { snippet_path(@snippet).should == "/snippets/#{@snippet.id}" }
      end

      describe 'edit_snippet_path' do
        specify { edit_snippet_path(@snippet).should == "/snippets/#{@snippet.id}/edit" }
      end

      describe 'edit_snippet_path' do
        specify { edit_snippet_path(@snippet).should == "/snippets/#{@snippet.id}/edit" }
      end
    end
  end
end
