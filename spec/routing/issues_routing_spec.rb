require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe IssuesController do
  describe 'routing' do
    specify { get('/issues').should map('issues#index') }
    specify { get('/issues/new').should map('issues#new') }
    specify { get('/issues/123').should map('issues#show', :id => '123') }
    specify { get('/issues/123/edit').should map('issues#edit', :id => '123') }
    specify { put('/issues/123').should map('issues#update', :id => '123') }
    specify { delete('/issues/123').should map('issues#destroy', :id => '123') }
    specify { post('/issues').should map('issues#create') }

    describe 'index pagination' do
      specify { get('/issues/page/2').should map('issues#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/issues/page/foo').should_not be_routable
      end
    end

    describe 'non-RESTful routes' do
      specify { get('/issues/search').should map('issues#search') }
      specify { post('/issues/search').should map('issues#search') }
    end

    describe 'helpers' do
      before do
        @issue = Issue.stub :id => 123
      end

      describe 'issues_path' do
        specify { issues_path.should == '/issues' }
      end

      describe 'new_issue_path' do
        specify { new_issue_path.should == '/issues/new' }
      end

      describe 'issue_path' do
        specify { issue_path(@issue).should == '/issues/123' }
      end

      describe 'edit_issue_path' do
        specify { edit_issue_path(@issue).should == '/issues/123/edit' }
      end

      describe 'edit_issue_path' do
        specify { edit_issue_path(@issue).should == '/issues/123/edit' }
      end
    end
  end
end
