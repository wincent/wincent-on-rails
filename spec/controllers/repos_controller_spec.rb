require 'spec_helper'

describe ReposController do
  describe '#index' do
    it 'renders repos/index' do
      get :index
      expect(response).to render_template('repos/index')
    end

    it 'succeeds' do
      get :index
      expect(response).to be_success
    end

    it 'finds and assigns public repos' do
      repo  = Repo.make! :public => true
      other = Repo.make! :public => false
      get :index
      expect(assigns[:repos]).to eq([repo])
    end
  end

  describe '#new' do
    it_has_behavior 'require_admin'

    def do_request
      get :new
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'assigns a new repo instance' do
        do_request
        expect(assigns[:repo]).to be_kind_of(Repo)
        expect(assigns[:repo]).to be_new_record
      end

      it 'renders repos/new' do
        do_request
        expect(response).to render_template('repos/new')
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
      end
    end
  end

  describe '#create' do
    it_has_behavior 'require_admin'

    before do
      @params = { 'repo' => Repo.valid_attributes.stringify_keys }
    end

    def do_request
      post :create, @params
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      context 'successful creation' do
        before do
          do_request
        end

        it 'creates a new repo record' do
          expect(assigns[:repo]).to be_kind_of(Repo)
          expect(assigns[:repo]).not_to be_new_record
        end

        it 'shows a flash' do
          expect(flash[:notice]).to match(/successfully created/i)
        end

        it 'redirects to #show' do
          expect(response).to redirect_to(repo_path(assigns[:repo]))
        end
      end

      context 'failed creation' do
        before do
          stub.instance_of(Repo).save { false }
          do_request
        end

        it 'assigns a new repo instance' do
          expect(assigns[:repo]).to be_kind_of(Repo)
          expect(assigns[:repo]).to be_new_record
        end

        it 'shows a flash' do
          expect(flash[:error]).to match(/failed to create/i)
        end

        it 'renders #new' do
          expect(response).to render_template('repos/new')
        end
      end
    end
  end

  describe '#show' do
    let(:repo) { Repo.make! }

    it 'finds and assigns the repo' do
      get :show, :id => repo.to_param
      expect(assigns[:repo]).to eq(repo)
    end

    it 'renders "repos/show"' do
      get :show, :id => repo.to_param
      expect(response).to render_template('repos/show')
    end

    it 'succeeds' do
      get :show, :id => repo.to_param
      expect(response).to be_success
    end

    context 'non-existent repo' do
      it 'redirects to #index' do
        get :show, :id => 50_000
        expect(response).to redirect_to('/repos')
      end

      it 'shows a flash' do
        get :show, :id => 50_000
        expect(flash[:error]).to match(/not found/i)
      end
    end

    context 'private repo' do
      let(:repo) { Repo.make! :public => false }

      it 'redirects to #index' do
        get :show, :id => repo.to_param
        expect(response).to redirect_to('/repos')
      end

      it 'shows a flash' do
        get :show, :id => repo.to_param
        expect(flash[:error]).to match(/not found/i)
      end
    end
  end

  describe '#edit' do
    let(:repo) { Repo.make! }

    it_has_behavior 'require_admin'

    def do_request
      get :edit, :id => repo.to_param
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the repo' do
        get :edit, :id => repo.to_param
        expect(assigns[:repo]).to eq(repo)
      end

      it 'renders "repos/edit"' do
        get :edit, :id => repo.to_param
        expect(response).to render_template('repos/edit')
      end

      it 'succeeds' do
        get :edit, :id => repo.to_param
        expect(response).to be_success
      end

      context 'non-existent repo' do
        it 'redirects to #index' do
          get :edit, :id => 50_000
          expect(response).to redirect_to('/repos')
        end

        it 'edits a flash' do
          get :edit, :id => 50_000
          expect(flash[:error]).to match(/not found/i)
        end
      end

      context 'private repo' do
        let(:repo) { Repo.make! :public => false }

        it 'redirects to #index' do
          get :edit, :id => repo.to_param
          expect(response).to redirect_to('/repos')
        end

        it 'shows a flash' do
          get :edit, :id => repo.to_param
          expect(flash[:error]).to match(/not found/i)
        end
      end
    end
  end

  describe '#update' do
    it_has_behavior 'require_admin'

    let(:repo) { Repo.make! }

    before do
      @params = {
        :id => repo.to_param,
        :repo => { 'name' => 'new and improved' }
      }
    end

    def do_request
      put :update, @params
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the repo' do
        do_request
        expect(assigns[:repo]).to eq(repo.reload)
      end

      context 'successful update' do
        it 'shows a flash' do
          do_request
          expect(flash[:notice]).to match(/successfully updated/i)
        end

        it 'redirects to #show' do
          do_request
          expect(response).to redirect_to(repo_path(repo))
        end

        it 'updates the instance' do
          do_request
          expect(repo.reload.name).to eq('new and improved')
        end
      end

      context 'failed update' do
        before do
          stub.instance_of(Repo).update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/update failed/i)
        end

        it 'renders #edit' do
          do_request
          expect(response).to render_template('repos/edit')
        end
      end
    end
  end

  describe '#destroy' do
    it_has_behavior 'require_admin'

    let (:repo) { Repo.make! }

    def do_request
      delete :destroy, :id => repo.to_param
    end

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'destroys the repo' do
        do_request
        expect do
          Repo.find repo.id
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'redirects to #index' do
        do_request
        expect(response).to redirect_to(repos_path)
      end

      it 'shows a flash' do
        do_request
        expect(flash[:notice]).to match(/successfully destroyed/i)
      end

      context 'non-existent repo' do
        def do_request
          delete :destroy, :id => 'bloomwang'
        end

        it 'redirects to #index' do
          do_request
          expect(response).to redirect_to(repos_path)
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/not found/i)
        end
      end
    end
  end
end
