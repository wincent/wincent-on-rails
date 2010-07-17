require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ResetsController do
  it_should_behave_like 'ApplicationController protected methods'

  describe '#new' do
    it 'assigns a new reset' do
      get :new
      assigns[:reset].should be_kind_of(Reset)
      assigns[:reset].should be_new_record
    end

    it 'renders the resets/new template' do
      get :new
      response.should render_template('resets/new')
    end

    it 'succeeds' do
      get :new
      response.should be_success
    end
  end

  describe '#create' do
    context 'with a valid email address' do
      before do
        @email = Email.make! :address => 'jessica@example.com'
      end

      def do_post
        post :create, :reset => { :email_address => 'jessica@example.com' }
      end

      it 'sends a reset message' do
        mock.proxy(ResetMailer).reset_message(is_a Reset)
        mock(controller).deliver(is_a Mail::Message)
        do_post
      end

      it 'redirects to /login' do
        do_post
        response.should redirect_to('/login')
      end

      context 'too many resets' do
        before do
          6.times { Reset.make! :email => @email }
        end

        it 'shows a flash' do
          do_post
          cookie_flash['error'].should =~ /exceeded the resets limit/
        end
      end
    end

    context 'without a valid email address' do
      def do_post
        post :create, :reset => { :email_address => 'unknown@example.com' }
      end

      it 'assigns a new reset' do
        do_post
        assigns[:reset].should be_kind_of(Reset)
        assigns[:reset].should be_new_record
      end

      it 'shows a flash' do
        do_post
        cookie_flash['error'].should =~ /invalid email address/i
      end

      it 'renders resets/new' do
        do_post
        response.should render_template('resets/new')
      end
    end
  end

  describe '#show' do
    it 'redirects to #edit' do
      get :show, :id => 'foobar'
      response.should redirect_to('/resets/foobar/edit')
    end
  end

  describe '#edit' do
    let(:reset) { Reset.make! }

    def do_get
      get :edit, :id => reset.secret
    end

    it 'finds and assigns the reset' do
      do_get
      assigns(:reset).should == reset
    end

    it 'finds and assigns the user' do
      do_get
      assigns(:user).should == reset.email.user
    end

    it 'renders resets/edit' do
      do_get
      response.should render_template('resets/edit')
    end

    it 'succeeds' do
      do_get
      response.should be_success
    end

    context 'no reset token found' do
      let(:reset) { Reset.make :secret => 'non-existent' }

      it 'shows a flash' do
        do_get
        cookie_flash['error'].should =~ /token not found/
      end

      it 'redirects to /' do
        do_get
        response.should redirect_to('/')
      end
    end

    context 'token already used' do
      let(:reset) { Reset.make! :completed_at => 3.days.ago }

      it 'shows a flash' do
        do_get
        cookie_flash['notice'].should =~ /token already used/
      end

      it 'redirects to /login' do
        do_get
        response.should redirect_to('/login')
      end
    end

    context 'expired token' do
      let(:reset) { Reset.make! :cutoff => 1.month.ago }

      it 'shows a flash' do
        do_get
        cookie_flash['error'].should =~ /expiry date has already passed/
      end

      it 'redirects to /' do
        do_get
        response.should redirect_to('/')
      end
    end
  end

  describe '#update' do
    let(:reset) { Reset.make! }

    def do_put
      put :update,
          :id => reset.secret,
          :reset => { :email_address => reset.email.address },
          :passphrase => 'helloworld',
          :passphrase_confirmation => 'helloworld'
      reset.reload
    end

    it 'finds and assigns reset' do
      do_put
      assigns[:reset].should == reset
    end

    it 'finds and assigns user' do
      do_put
      assigns[:user].should == reset.email.user
    end

    it 'sets the new passphrase' do
      do_put
      User.authenticate(reset.email.address, 'helloworld').
        should == reset.email.user
    end

    it 'sets completed_at' do
      do_put
      (reset.completed_at - Time.now).should < 1.second
    end

    it 'shows a flash' do
      do_put
      cookie_flash['notice'].should =~ /updated passphrase/
    end

    it 'logs in' do
      do_put
      controller.send(:current_user).should == reset.email.user
    end

    it 'redirects to the user dashboard' do
      do_put
      response.should redirect_to('/dashboard')
    end

    context 'reset invalid (incorrect email address)' do
      def do_put
        put :update,
            :id => reset.secret,
            :reset => { :email_address => 'nobody@example.com' },
            :passphrase => 'helloworld',
            :passphrase_confirmation => 'helloworld'
        reset.reload
      end

      it 'does not set completed_at' do
        do_put
        reset.completed_at.should be_nil
      end

      it 'does not reset the passphrase' do
        do_put
        User.authenticate(reset.email.address, 'helloworld').
          should_not == reset.email.user
      end

      it 'renders resets/edit' do
        do_put
        response.should render_template('resets/edit')
      end
    end

    context 'user invalid (incorrect passphrase confirmation)' do
      def do_put
        put :update,
            :id => reset.secret,
            :reset => { :email_address => reset.email.address },
            :passphrase => 'one thing',
            :passphrase_confirmation => 'another thing'
        reset.reload
      end

      it 'does not set completed_at' do
        do_put
        reset.completed_at.should be_nil
      end

      it 'does not reset the passphrase' do
        do_put
        User.authenticate(reset.email.address, 'one thing').
          should_not == reset.email.user
      end

      it 'render resets/edit' do
        do_put
        response.should render_template('resets/edit')
      end
    end

    context 'reset not found' do
      # potentially should be a shared behavior this one, as it
      # is the standard record_not_found method from ApplicationController
      def do_put
        put :update, :id => 'non-existent'
      end

      it 'shows a flash' do
        do_put
        # BUG: in test environment, any flash set in the record_not_found
        # method will not hit the cookie flash
        flash[:error].should =~ /not found/
      end

      it 'redirects to /' do
        do_put
        response.should redirect_to('/')
      end
    end
  end
end
