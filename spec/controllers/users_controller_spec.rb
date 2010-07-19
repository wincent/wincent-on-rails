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

  describe '#create' do
    before do
      # must use string keys because that's what Rails will pass to controller
      # (otherwise our mock expectations won't match)
      @params = { 'user' => User.valid_attributes.stringify_keys }
    end

    def do_post
      post :create, @params
    end

    it 'makes a new user' do
      mock.proxy(User).new @params['user']
      do_post
    end

    it 'assigns the new user' do
      do_post
      assigns[:user].should be_kind_of(User)
    end

    context 'successful creation' do
      it 'creates a confirmation' do
        do_post
        assigns[:user].emails.first.confirmations.size.should == 1
      end

      it 'creates a confirmation message' do
        mock.proxy(ConfirmationMailer).confirmation_message(is_a Confirmation)
        do_post
      end

      it 'delivers the confirmation message' do
        mock(controller).deliver is_a(Mail::Message)
        do_post
      end

      it 'redirects to /dashboard' do
        do_post
        response.should redirect_to('/dashboard')
      end

      it 'logs in automatically' do
        do_post
        user = assigns[:user].reload
        user.session_expiry.should > Time.now
      end
    end

    context 'failed creation' do
      before do
        stub.instance_of(User).save { false }
        do_post
      end

      it 'shows a flash' do
        cookie_flash['error'].should =~ /failed to create/i
      end

      it 'renders users/new' do
        response.should render_template('users/new')
      end
    end
  end

  describe '#show' do
    before do
      @user = User.make! :display_name => 'Henry Krinkle'
    end

    def do_get
      get :show, :id => 'henry-krinkle'
    end

    it 'finds and assigns the user' do
      do_get
      assigns[:user].should == @user
    end

    it 'renders users/show' do
      do_get
      response.should render_template('users/show')
    end

    it 'succeeds' do
      do_get
      response.should be_success
    end
  end
end
