require 'spec_helper'

describe BranchesController do
  let(:repo) { Repo.make! }

  it 'uses stylesheet links' do
    BranchesController.uses_stylesheet_links?.should be_true
  end

  describe '#index' do
    def do_request
      get :index, :repo_id => repo.to_param
    end

    it 'finds and assigns repo' do
      do_request
      assigns[:repo].should == repo
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/

        # would prefer to write this as follows
        pending 'after filters not running in test suite'
        cookie_flash[:error].should =~ /not found/i
        # TODO: investigate this further and possibly post
        # to RSpec mailing list
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    context 'non-existent repo' do
      let(:repo) { Repo.make } # don't save repo to database

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in test suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    it 'redirects to the repo branch listing' do
      do_request
      response.should redirect_to(repo_path(repo) + '#branches')
    end
  end

  describe '#show' do
    before do
      @branch = 'master'
    end

    def do_request
      get :show, :repo_id => repo.to_param, :id => @branch
    end

    it 'finds and assigns repo' do
      do_request
      assigns[:repo].should == repo
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in test suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    context 'non-existent repo' do
      let(:repo) { Repo.make } # don't save repo to database

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in test suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    it 'finds and assigns the branch' do
      do_request
      assigns[:branch].should be_kind_of(Git::Branch)
      assigns[:branch].name.should == 'refs/heads/master'
    end

    context 'non-existent branch' do
      before do
        @branch = 'foobar'
      end

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in test suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#show' do
        do_request
        response.should redirect_to(repo_path(repo))
      end
    end

    it 'assigns the commits on the branch' do
      do_request
      assigns[:commits].should be_kind_of(Array)
      assigns[:commits].all? do |c|
        c.kind_of? Git::Commit
      end.should be_true
    end

    it 'renders "branches/show"' do
      do_request
      response.should render_template('branches/show')
    end
  end
end
