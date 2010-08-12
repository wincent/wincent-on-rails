require 'spec_helper'

describe ReposController do
  describe '#index' do
    it 'renders repos/index' do
      get :index
      response.should render_template('repos/index')
    end

    it 'succeeds' do
      get :index
      response.should be_success
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
        assigns[:repo].should be_kind_of(Repo)
        assigns[:repo].should be_new_record
      end

      it 'renders repos/new' do
        do_request
        response.should render_template('repos/new')
      end

      it 'succeeds' do
        do_request
        response.should be_success
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
          assigns[:repo].should be_kind_of(Repo)
          assigns[:repo].should_not be_new_record
        end

        it 'shows a flash' do
          cookie_flash[:notice].should =~ /successfully created/i
        end

        it 'redirects to #show' do
          response.should redirect_to(repo_path(assigns[:repo]))
        end
      end

      context 'failed creation' do
        before do
          stub.instance_of(Repo).save { false }
          do_request
        end

        it 'assigns a new repo instance' do
          assigns[:repo].should be_kind_of(Repo)
          assigns[:repo].should be_new_record
        end

        it 'shows a flash' do
          cookie_flash[:error].should =~ /failed to create/i
        end

        it 'renders #new' do
          response.should render_template('repos/new')
        end
      end
    end
  end

  describe '#show' do
    let(:repo) { Repo.make! }

    it 'finds and assigns the repo' do
      get :show, :id => repo.to_param
      assigns[:repo].should == repo
    end

    it 'renders "repos/show"' do
      get :show, :id => repo.to_param
      response.should render_template('repos/show')
    end

    it 'succeeds' do
      get :show, :id => repo.to_param
      response.should be_success
    end

    context 'non-existent repo' do
      it 'redirects to #index' do
        get :show, :id => 50_000
        response.should redirect_to('/repos')
      end
    end
  end
end
