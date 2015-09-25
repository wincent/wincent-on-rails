require 'spec_helper'

describe IssuesController do
  describe 'routing' do
    specify { expect(get: '/issues').to route_to('issues#index') }
    specify { expect(get: '/issues/123').to route_to('issues#show', id: '123') }

    describe 'index pagination' do
      specify { expect(get: '/issues/page/2').to route_to('issues#index', page: '2') }

      it 'rejects non-numeric :page params' do
        expect(get: '/issues/page/foo').to_not be_routable
      end
    end

    describe 'non-RESTful routes' do
      specify { expect(get: '/issues/search').to route_to('issues#search') }
    end

    describe 'helpers' do
      let(:issue) { Issue.stub }

      describe 'issues_path' do
        specify { expect(issues_path).to eq('/issues') }
      end

      describe 'issue_path' do
        specify { expect(issue_path(issue)).to eq("/issues/#{issue.id}") }
      end
    end
  end
end
