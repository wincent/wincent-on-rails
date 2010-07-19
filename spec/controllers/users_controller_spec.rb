require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe UsersController do
  describe '#index' do
    def do_request
      get :index
    end

    it_should_behave_like 'require_admin'

    context 'as admin' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns users' do
        2.times { User.make! } # plus 1 admin user from log_in_as_admin
        do_request
        assigns[:users].to_a.should =~ User.all
      end

      it 'renders users/index' do
        do_request
        response.should render_template('users/index')
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end
    end
  end

  describe '#new' do
    it 'assigns a new user' do
      get :new
      assigns[:user].should be_kind_of(User)
      assigns[:user].should be_new_record
    end

    it 'assigns a new email' do
      get :new
      assigns[:email].should be_kind_of(Email)
      assigns[:email].should be_new_record
    end

    it 'associates the email with the user' do
      stub(User).new.mock!.emails.mock!.build
      get :new
    end

    it 'renders users/new' do
      get :new
      response.should render_template('users/new')
    end

    it 'succeeds' do
      get :new
      response.should be_success
    end
  end
end
