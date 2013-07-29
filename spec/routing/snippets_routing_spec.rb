require 'spec_helper'

describe SnippetsController do
  describe 'routing' do
    specify do
      expect(get: '/snippets').to route_to('snippets#index')
    end

    specify do
      expect(get: '/snippets/new').to route_to('snippets#new')
    end

    specify do
      expect(get: '/snippets/123').to route_to('snippets#show', id: '123')
    end

    specify do
      expect(get: '/snippets/123/edit').
        to route_to('snippets#edit', id: '123')
    end

    specify do
      expect(put: '/snippets/123').to route_to('snippets#update', id: '123')
    end

    specify do
      expect(delete: '/snippets/123').
        to route_to('snippets#destroy', id: '123')
    end

    specify do
      expect(post: '/snippets').to route_to('snippets#create')
    end

    describe 'index pagination' do
      specify do
        expect(get: '/snippets/page/2').
          to route_to('snippets#index', page: '2')
      end

      it 'rejects non-numeric :page params' do
        expect(get: '/snippets/page/foo').to_not be_routable
      end
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify do
        expect(get: '/snippets/123/comments/new').
          to route_to('comments#new', snippet_id: '123')
      end

      specify do
        expect(post: '/snippets/123/comments').
          to route_to('comments#create', snippet_id: '123')
      end

      specify do
        expect(put: '/snippets/123/comments/456').
          to route_to('comments#update', snippet_id: '123', id: '456')
      end

      # all other RESTful actions are no-ops
      specify do
        expect(get: '/snippets/123/comments').to_not be_routable
      end

      specify do
        expect(get: '/snippets/123/comments/456').to_not be_routable
      end

      specify do
        expect(get: '/snippets/123/comments/456/edit').to_not be_routable
      end

      specify do
        expect(delete: '/snippets/123/comments/456').to_not be_routable
      end
    end

    describe 'helpers' do
      let(:snippet) { Snippet.stub }

      describe 'snippets_path' do
        specify { expect(snippets_path).to eq('/snippets') }
      end

      describe 'new_snippet_path' do
        specify { expect(new_snippet_path).to eq('/snippets/new') }
      end

      describe 'snippet_path' do
        specify { expect(snippet_path(snippet)).to eq("/snippets/#{snippet.id}") }
      end

      describe 'edit_snippet_path' do
        specify { expect(edit_snippet_path(snippet)).to eq("/snippets/#{snippet.id}/edit") }
      end

      describe 'edit_snippet_path' do
        specify { expect(edit_snippet_path(snippet)).to eq("/snippets/#{snippet.id}/edit") }
      end
    end
  end
end
