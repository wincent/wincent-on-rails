require 'spec_helper'

describe IssuesController do
  describe 'routing' do
    specify { get('/issues').should have_routing('issues#index') }
    specify { get('/issues/new').should have_routing('issues#new') }
    specify { get('/issues/123').should have_routing('issues#show', :id => '123') }
    specify { get('/issues/123/edit').should have_routing('issues#edit', :id => '123') }
    specify { put('/issues/123').should have_routing('issues#update', :id => '123') }
    specify { delete('/issues/123').should have_routing('issues#destroy', :id => '123') }
    specify { post('/issues').should have_routing('issues#create') }

    describe 'index pagination' do
      specify { get('/issues/page/2').should have_routing('issues#index', :page => '2') }

      it 'rejects non-numeric :page params' do
        get('/issues/page/foo').should_not be_recognized
      end
    end

    describe 'non-RESTful routes' do
      specify { get('/issues/search').should have_routing('issues#search') }
    end

    describe 'comments' do
      # only #new, #create and #update are implemented while nested
      specify { get('/issues/123/comments/new').should have_routing('comments#new', :issue_id => '123') }
      specify { post('/issues/123/comments').should have_routing('comments#create', :issue_id => '123') }
      specify { put('/issues/123/comments/456').should have_routing('comments#update', :issue_id => '123', :id => '456') }

      # all other RESTful actions are no-ops
      specify { get('/issues/123/comments').should_not be_recognized }
      specify { get('/issues/123/comments/456').should_not be_recognized }
      specify { get('/issues/123/comments/456/edit').should_not be_recognized }
      specify { delete('/issues/123/comments/456').should_not be_recognized }
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
