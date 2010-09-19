require 'spec_helper'

describe CommitsController do
  let(:repo) { Repo.make! }

  it 'uses stylesheet links' do
    CommitsController.uses_stylesheet_links?.should be_true
  end

  describe '#index' do
    def do_request
      get :index , :repo_id => repo.to_param
    end

    it 'finds and assigns the repo' do
      do_request
      assigns[:repo].should == repo
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in spec suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    context 'non-existent repo' do
      let(:repo) { Repo.make } # don't save repo to db

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in spec suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    it 'redirects to the repo commit listing' do
      do_request
      response.should redirect_to(repo_path(repo) + '#commits')
    end
  end

  describe '#show' do
    before do
      @commit = repo.repo.head.sha1
    end

    def do_request
      get :show, :repo_id => repo.to_param, :id => @commit
    end

    it 'finds and assigns the repo' do
      do_request
      assigns[:repo].should == repo
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in spec suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    context 'non-existent repo' do
      let(:repo) { Repo.make } # don't save repo to db

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in spec suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#index' do
        do_request
        response.should redirect_to(repos_path)
      end
    end

    it 'finds and assigns the commit' do
      do_request
      assigns[:commit].should be_kind_of(Git::Commit)
      assigns[:commit].commit.should == @commit
    end

    context 'non-existent commit' do
      before do
        @commit = '0' * 40
      end

      it 'shows a flash' do
        do_request
        flash[:error].should =~ /not found/
        pending 'after filters not running in spec suite'
        cookie_flash[:error].should =~ /not found/
      end

      it 'redirects to repos#show' do
        do_request
        response.should redirect_to(repo_path(repo))
      end
    end

    it 'renders "commits/show"' do
      do_request
      response.should render_template('commits/show')
    end
  end
end
