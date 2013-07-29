require 'spec_helper'

describe IssuesController do
  describe 'routing' do
    specify { expect(get: '/issues').to route_to('issues#index') }
    specify { expect(get: '/issues/new').to route_to('issues#new') }
    specify { expect(get: '/issues/123').to route_to('issues#show', id: '123') }
    specify { expect(get: '/issues/123/edit').to route_to('issues#edit', id: '123') }
    specify { expect(put: '/issues/123').to route_to('issues#update', id: '123') }
    specify { expect(delete: '/issues/123').to route_to('issues#destroy', id: '123') }
    specify { expect(post: '/issues').to route_to('issues#create') }

    describe 'index pagination' do
      specify { expect(get: '/issues/page/2').to route_to('issues#index', page: '2') }

      it 'rejects non-numeric :page params' do
        expect(get: '/issues/page/foo').to_not be_routable
      end
    end

    describe 'non-RESTful routes' do
      specify { expect(get: '/issues/search').to route_to('issues#search') }
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { expect(get: '/issues/123/comments/new').to route_to('comments#new', issue_id: '123') }
      specify { expect(post: '/issues/123/comments').to route_to('comments#create', issue_id: '123') }
      specify { expect(put: '/issues/123/comments/456').to route_to('comments#update', issue_id: '123', id: '456') }

      # all other RESTful actions are no-ops
      specify { expect(get: '/issues/123/comments').to_not be_routable }
      specify { expect(get: '/issues/123/comments/456').to_not be_routable }
      specify { expect(get: '/issues/123/comments/456/edit').to_not be_routable }
      specify { expect(delete: '/issues/123/comments/456').to_not be_routable }
    end

    describe 'helpers' do
      let(:issue) { Issue.stub }

      describe 'issues_path' do
        specify { expect(issues_path).to eq('/issues') }
      end

      describe 'new_issue_path' do
        specify { expect(new_issue_path).to eq('/issues/new') }
      end

      describe 'issue_path' do
        specify { expect(issue_path(issue)).to eq("/issues/#{issue.id}") }
      end

      describe 'edit_issue_path' do
        specify { expect(edit_issue_path(issue)).to eq("/issues/#{issue.id}/edit") }
      end

      describe 'edit_issue_path' do
        specify { expect(edit_issue_path(issue)).to eq("/issues/#{issue.id}/edit") }
      end
    end
  end
end
