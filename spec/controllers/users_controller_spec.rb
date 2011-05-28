require 'spec_helper'

describe UsersController do
  describe '#index' do
    def do_request
      get :index
    end

    it_has_behavior 'require_admin'

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
      stub(User).new.mock!.emails.mock!.new
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
        user = assigns[:user]
        user.session_expiry.should > Time.now
        request.env['action_dispatch.cookies']['user_id'].should == user.id.to_s
        request.env['action_dispatch.cookies']['session_key'].should == user.session_key
      end
    end

    context 'failed creation' do
      before do
        stub.instance_of(User).save { false }
        do_post
      end

      it 'shows a flash' do
        flash[:error].should =~ /failed to create/i
      end

      it 'renders users/new' do
        response.should render_template('users/new')
      end
    end
  end

  describe '#show' do
    let(:user) { User.make! }

    def do_get
      get :show, :id => user.to_param
    end

    it 'finds and assigns the user' do
      do_get
      assigns[:user].should == user
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

  describe '#edit' do
    let(:user) { User.make! }

    def do_request
      get :edit, :id => user.to_param
    end

    it_has_behavior 'require_user'

    context 'as a normal user' do
      before do
        log_in_as user
      end

      it 'finds and assigns the user' do
        do_request
        assigns[:user].should == user
      end

      it 'finds and assigns user emails' do
        do_request
        assigns[:emails].to_a.should == user.emails
      end

      it 'renders users/edit' do
        do_request
        response.should render_template('users/edit')
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end
    end

    context 'as an admin user' do
      before do
        log_in_as_admin
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end
    end

    context 'as a different user' do
      before do
        log_in_as User.make!
      end

      it 'shows a flash' do
        do_request
        flash[:notice].should =~ /not allowed to edit this user/
      end

      it 'redirects to user#show' do
        do_request
        response.should redirect_to(user)
      end
    end
  end

  describe '#update' do
    let(:user) { User.make! }

    before do
      @params = {
          'display_name'  => 'Henry Krinkle',
          'email'         => Sham.email_address
        }
    end

    def do_request
      put :update, {
        :id     => user.to_param,
        'user'  => @params
      }
    end

    it_has_behavior 'require_user'

    context 'as a normal user' do
      before do
        log_in_as user
      end

      it 'updates emails' do
        pending
        stub(User).find_with_param!(user.to_param) { user }
        do_request
      end

      it 'updates attributes' do
        stub(User).find_with_param!(user.to_param) { user }
        mock(user).update_attributes @params
        do_request
      end

      context 'new email address added' do
        it 'creates a confirmation' do
          do_request
          user.emails.last.confirmations.size.should == 1
        end

        it 'creates a confirmation message' do
          mock.proxy(ConfirmationMailer).confirmation_message(is_a Confirmation)
          do_request
        end

        it 'delivers the confirmation message' do
          mock(controller).deliver is_a(Mail::Message)
          do_request
        end

        it 'redirects to /dashboard' do
          do_request
          response.should redirect_to('/dashboard')
        end
      end

      context 'no new email address added' do
        before do
          @params.delete 'email'
        end

        it 'shows a flash' do
          do_request
          flash[:notice].should =~ /successfully updated/i
        end

        it 'redirects to #show' do
          do_request
          response.should redirect_to(user.reload)
        end
      end

      context 'failed update' do
        before do
          stub(User).find_with_param!(user.to_param) { user }
          stub(user).update_attributes { false }
          @params.delete 'email'
        end

        it 'finds and assigns emails' do
          do_request
          assigns[:emails].to_a.should == user.emails
        end

        it 'shows a flash' do
          do_request
          flash[:error].should =~ /update failed/i
        end

        it 'renders users/edit' do
          do_request
          response.should render_template('users/edit')
        end
      end
    end
  end
end
