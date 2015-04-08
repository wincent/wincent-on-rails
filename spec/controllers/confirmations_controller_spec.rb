require 'spec_helper'

describe ConfirmationsController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#new' do
    context 'as a logged in user' do
      before do
        log_in
      end

      it 'assigns a new confirmation object' do
        get :new
        expect(assigns[:confirmation]).to be_kind_of(Confirmation)
        expect(assigns[:confirmation]).to be_new_record
      end

      it 'renders the confirmations/new template' do
        get :new
        expect(response).to render_template('confirmations/new')
      end

      it 'succeeds' do
        get :new
        expect(response).to be_success
      end
    end

    context 'as an anonymous user' do
      it 'redirects to the login page' do
        get :new
        expect(response).to redirect_to('/login')
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
          expect { do_post }.
            to change { @unverified.confirmations.count }.by(1)
        end

        it 'sends a confirmation message' do
          mock.proxy(ConfirmationMailer).confirmation_message(is_a Confirmation)
          mock(controller).deliver(is_a ActionMailer::MessageDelivery)
          do_post
        end

        it 'shows a flash on success' do
          do_post
          expect(flash[:notice].first).to match(/sent to #{@unverified.address}/)
        end

        it 'shows a flash on failure' do
          stub.instance_of(ActionMailer::MessageDelivery).deliver_now { raise }
          do_post
          expect(flash[:error].first).to match(/an error occurred/i)
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
        expect(response).to redirect_to(user_path @user)
      end
    end

    context 'as an anonymous user' do
      it 'redirects to the login page' do
        post :create
        expect(response).to redirect_to('/login')
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
        expect(response).to redirect_to('/')
      end

      it 'shows a flash' do
        do_get
        expect(flash[:error]).to match(/not found/)
      end
    end

    context 'confirmation already done' do
      let(:confirmation) { Confirmation.make! :completed_at => 2.days.ago }

      it 'redirects to /login' do
        do_get
        expect(response).to redirect_to('/login')
      end

      it 'shows a flash' do
        do_get
        expect(flash[:notice]).to match(/already confirmed/)
      end
    end

    context 'expiry date passed' do
      let(:confirmation) { Confirmation.make! :cutoff => 2.days.ago }

      it 'redirects to /' do
        do_get
        expect(response).to redirect_to('/')
      end

      it 'shows a flash' do
        do_get
        expect(flash[:error]).to match(/expiry date has already passed/)
      end
    end

    context 'a valid confirmation' do
      let(:confirmation) { Confirmation.make! :email => @email }

      before do
        do_get
        confirmation.reload
      end

      it 'sets completed_at' do
        expect(confirmation.completed_at - Time.now).tobe < 1.second
      end

      it 'marks the associated email as verified' do
        expect(confirmation.email.verified).to eq(true)
      end

      it 'marks the associated user as verified' do
        expect(confirmation.email.user.verified).to eq(true)
      end

      it 'shows a flash' do
        expect(flash[:notice]).to match(/successfully confirmed email/i)
      end

      it 'redirects to /dashboard' do
        expect(response).to redirect_to('/dashboard')
      end
    end
  end
end
