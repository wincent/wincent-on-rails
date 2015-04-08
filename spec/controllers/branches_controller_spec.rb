require 'spec_helper'

describe BranchesController do
  let(:repo) { Repo.make! }

  describe '#index' do
    def do_request
      get :index, :repo_id => repo.to_param
    end

    it 'finds and assigns repo' do
      do_request
      expect(assigns[:repo]).to eq(repo)
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'shows a flash' do
        do_request
        expect(flash[:error]).to match(/not found/)
      end

      it 'redirects to repos#index' do
        do_request
        expect(response).to redirect_to(repos_path)
      end
    end

    context 'non-existent repo' do
      let(:repo) { Repo.make } # don't save repo to database

      it 'shows a flash' do
        do_request
        expect(flash[:error]).to match(/not found/)
      end

      it 'redirects to repos#index' do
        do_request
        expect(response).to redirect_to(repos_path)
      end
    end

    it 'redirects to the repo branch listing' do
      do_request
      expect(response).to redirect_to(repo_path(repo) + '#branches')
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
      expect(assigns[:repo]).to eq(repo)
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'shows a flash' do
        do_request
        expect(flash[:error]).to match(/not found/)
      end

      it 'redirects to repos#index' do
        do_request
        expect(response).to redirect_to(repos_path)
      end
    end

    context 'non-existent repo' do
      let(:repo) { Repo.make } # don't save repo to database

      it 'shows a flash' do
        do_request
        expect(flash[:error]).to match(/not found/)
      end

      it 'redirects to repos#index' do
        do_request
        expect(response).to redirect_to(repos_path)
      end
    end

    it 'finds and assigns the branch' do
      do_request
      expect(assigns[:branch]).to be_kind_of(Git::Branch)
      expect(assigns[:branch].name).to eq('refs/heads/master')
    end

    context 'non-existent branch' do
      before do
        @branch = 'foobar'
      end

      it 'shows a flash' do
        do_request
        expect(flash[:error]).to match(/not found/)
      end

      it 'redirects to repos#show' do
        do_request
        expect(response).to redirect_to(repo_path(repo))
      end
    end

    it 'assigns the commits on the branch' do
      do_request
      expect(assigns[:commits]).to be_kind_of(Array)
      expect(assigns[:commits].all? do |c|
        c.kind_of? Git::Commit
      end).to eq(true)
    end

    it 'renders "branches/show"' do
      do_request
      expect(response).to render_template('branches/show')
    end
  end
end
