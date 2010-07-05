require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe IssuesController do
  describe 'routing' do
    example 'GET /issues' do
      get('/issues').should map('issues#index')
    end

    example 'GET /issues/new' do
      get('/issues/new').should map('issues#new')
    end

    example 'GET /issues/:id' do
      get('/issues/123').should map('issues#show', :id => '123')
    end

    example 'GET /issues/:id/edit' do
      get('/issues/123/edit').should map('issues#edit', :id => '123')
    end

    example 'PUT /issues/:id' do
      put('/issues/123').should map('issues#update', :id => '123')
    end

    example 'DELETE /issues/:id' do
      delete('/issues/123').should map('issues#destroy', :id => '123')
    end

    example 'POST /issues' do
      post('/issues').should map('issues#create')
    end

    # alternative syntax, still not sure if I prefer it
    it { get('/issues').should map('issues#index') }
    it { get('/issues/new').should map('issues#new') }
    it { get('/issues/123').should map('issues#show', :id => '123') }
    it { get('/issues/123/edit').should map('issues#edit', :id => '123') }
    it { put('/issues/123').should map('issues#update', :id => '123') }
    it { delete('/issues/123').should map('issues#destroy', :id => '123') }
    it { post('/issues').should map('issues#create') }

    describe 'index pagination' do
      example 'GET /issues/page/2' do
        get('/issues/page/2').should map_to('issues#index', :page => '2')
      end
    end

    describe 'non-RESTful routes' do
      example 'GET /issues/search' do
        get('/issues/search').should map('issues#search')
      end

      example 'POST /issues/search' do
        post('/issues/search').should map('issues#search')
      end
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

      describe 'paginated_issues_path' do
        it { paginated_issues_path(:page => 2).should == '/issues/page/2' }
      end

      describe 'edit_issue_path' do
        it { edit_issue_path(@issue).should == '/issues/123/edit' }
      end

      describe 'paginated_issues_path' do
        it { paginated_issues_path(:page => 2).should == '/issues/page/2' }
      end
    end
  end
end
