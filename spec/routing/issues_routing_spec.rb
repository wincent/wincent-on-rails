require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe IssuesController do
  describe 'routing' do
    it { get('/issues').should map('issues#index') }
    it { get('/issues/new').should map('issues#new') }
    it { get('/issues/123').should map('issues#show', :id => '123') }
    it { get('/issues/123/edit').should map('issues#edit', :id => '123') }
    it { put('/issues/123').should map('issues#update', :id => '123') }
    it { delete('/issues/123').should map('issues#destroy', :id => '123') }
    it { post('/issues').should map('issues#create') }

    describe 'index pagination' do
      it { get('/issues/page/2').should map('issues#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/issues/page/foo').should_not be_routable
      end
    end

    describe 'non-RESTful routes' do
      it { get('/issues/search').should map('issues#search') }
      it { post('/issues/search').should map('issues#search') }
    end

    describe 'helpers' do
      before do
        @issue = Issue.stub :id => 123
      end

      describe 'issues_path' do
        it { issues_path.should == '/issues' }
      end

      describe 'new_issue_path' do
        it { new_issue_path.should == '/issues/new' }
      end

      describe 'issue_path' do
        it { issue_path(@issue).should == '/issues/123' }
      end

      describe 'edit_issue_path' do
        it { edit_issue_path(@issue).should == '/issues/123/edit' }
      end

      describe 'edit_issue_path' do
        it { edit_issue_path(@issue).should == '/issues/123/edit' }
      end
    end
  end
end
