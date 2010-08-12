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
end
