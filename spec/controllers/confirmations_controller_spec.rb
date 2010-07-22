require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ConfirmationsController do
  it_has_behavior 'ApplicationController protected methods'

  describe '#new' do
    context 'as a logged in user' do
      before do
        log_in
      end

      it 'assigns a new confirmation object' do
        get :new
        assigns[:confirmation].should be_kind_of(Confirmation)
        assigns[:confirmation].should be_new_record
      end

      it 'renders the confirmations/new template' do
        get :new
        response.should render_template('confirmations/new')
      end

      it 'succeeds' do
        get :new
        response.should be_success
      end
    end

    context 'as an anonymous user' do
      it 'redirects to the login page' do
        get :new
        response.should redirect_to('/login')
      end
    end
  end

  describe '#create' do
    context 'as a logged-in user' do
      before do
        @user = User.make!
        log_in_as @user
      end

      context 'with an unconfirmed address' do
        before do
          @unverified = Email.make! :user => @user, :verified => false
        end

        def do_post
          post :create, :emails => { @unverified.id.to_s => '1' }
        end

        it 'creates a confirmation' do
          lambda { do_post }.
            should change { @unverified.confirmations.count }.by(1)
        end

        it 'sends a confirmation message' do
          mock.proxy(ConfirmationMailer).confirmation_message(is_a Confirmation)
          mock(controller).deliver(is_a Mail::Message)
          do_post
        end

        it 'shows a flash on success' do
          do_post
          cookie_flash['notice'].should =~ /sent to #{@unverified.address}/
        end

        it 'shows a flash on failure' do
          stub.instance_of(Mail::Message).deliver { raise }
          do_post
          cookie_flash['error'].should =~ /an error occurred/i
        end
      end

      context 'with a confirmed address' do
        # this code path can only be triggered if user hacks the form
        before do
          @verified = Email.make! :user => @user
        end

        def do_post
          post :create, :emails => { @verified.id.to_s => '1' }
        end

        it 'does nothing for already confirmed addresses' do
          do_not_allow(ConfirmationMailer).confirmation_message
          do_post
        end
      end

      it 'redirects to the user profile' do
        post :create
        response.should redirect_to(user_path @user)
      end
    end

    context 'as an anonymous user' do
      it 'redirects to the login page' do
        post :create
        response.should redirect_to('/login')
      end
    end
  end

  describe '#show' do
    before do
      @email = Email.make! :verified => false
      @user = @email.user
      @user.verified = false
      @user.save
    end

    def do_get
      get :show, :id => confirmation.secret
    end

    context 'confirmation does not exist' do
      let(:confirmation) { Confirmation.make :secret => 'blah' }

      it 'redirects to /' do
        do_get
        response.should redirect_to('/')
      end

      it 'shows a flash' do
        do_get
        cookie_flash['error'].should =~ /not found/
      end
    end

    context 'confirmation already done' do
      let(:confirmation) { Confirmation.make! :completed_at => 2.days.ago }

      it 'redirects to /login' do
        do_get
        response.should redirect_to('/login')
      end

      it 'shows a flash' do
        do_get
        cookie_flash['notice'].should =~ /already confirmed/
      end
    end

    context 'expiry date passed' do
      let(:confirmation) { Confirmation.make! :cutoff => 2.days.ago }

      it 'redirects to /' do
        do_get
        response.should redirect_to('/')
      end

      it 'shows a flash' do
        do_get
        cookie_flash['error'].should =~ /expiry date has already passed/
      end
    end

    context 'a valid confirmation' do
      let(:confirmation) { Confirmation.make! :email => @email }

      before do
        do_get
        confirmation.reload
      end

      it 'sets completed_at' do
        (confirmation.completed_at - Time.now).should< 1.second
      end

      it 'marks the associated email as verified' do
        confirmation.email.verified.should be_true
      end

      it 'marks the associated user as verified' do
        confirmation.email.user.verified.should be_true
      end

      it 'shows a flash' do
        cookie_flash['notice'].should =~ /successfully confirmed email/i
      end

      it 'redirects to /dashboard' do
        response.should redirect_to('/dashboard')
      end
    end
  end
end
