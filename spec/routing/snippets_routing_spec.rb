require 'spec_helper'

describe SnippetsController do
  describe 'routing' do
    specify { get('/snippets').should have_routing('snippets#index') }
    specify { get('/snippets/new').should have_routing('snippets#new') }
    specify { get('/snippets/123').should have_routing('snippets#show', :id => '123') }
    specify { get('/snippets/123/edit').should have_routing('snippets#edit', :id => '123') }
    specify { put('/snippets/123').should have_routing('snippets#update', :id => '123') }
    specify { delete('/snippets/123').should have_routing('snippets#destroy', :id => '123') }
    specify { post('/snippets').should have_routing('snippets#create') }

    describe 'index pagination' do
      specify { get('/snippets/page/2').should have_routing('snippets#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/snippets/page/foo').should_not be_recognized
      end
    end

    describe 'comments' do
      # only #new and #create are implemented while nested
      # Rails BUG?: only map_to works here; map_from (and therefore also have_routing) do not
      specify { get('/snippets/123/comments/new').should map_to('comments#new', :snippet_id => '123') }
      specify { post('/snippets/123/comments').should map_to('comments#create', :snippet_id => '123') }

      # all other RESTful actions are no-ops
      specify { get('/snippets/123/comments').should_not be_recognized }
      specify { get('/snippets/123/comments/456').should_not be_recognized }
      specify { get('/snippets/123/comments/456/edit').should_not be_recognized }
      specify { put('/snippets/123/comments/456').should_not be_recognized }
      specify { delete('/snippets/123/comments/456').should_not be_recognized }
    end

    describe 'helpers' do
      before do
        @snippet = Snippet.stub :id => 123
      end

      describe 'snippets_path' do
        specify { snippets_path.should == '/snippets' }
      end

      describe 'new_snippet_path' do
        specify { new_snippet_path.should == '/snippets/new' }
      end

      describe 'snippet_path' do
        specify { snippet_path(@snippet).should == '/snippets/123' }
      end

      describe 'edit_snippet_path' do
        specify { edit_snippet_path(@snippet).should == '/snippets/123/edit' }
      end

      describe 'edit_snippet_path' do
        specify { edit_snippet_path(@snippet).should == '/snippets/123/edit' }
      end
    end
  end
end
