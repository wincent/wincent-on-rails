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
        expect(assigns[:users].to_a).to match_array(User.all)
      end

      it 'renders users/index' do
        do_request
        expect(response).to render_template('users/index')
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
      end
    end
  end

  describe '#new' do
    it 'assigns a new user' do
      get :new
      expect(assigns[:user]).to be_kind_of(User)
      expect(assigns[:user]).to be_new_record
    end

    it 'assigns a new email' do
      get :new
      expect(assigns[:email]).to be_kind_of(Email)
      expect(assigns[:email]).to be_new_record
    end

    it 'associates the email with the user' do
      stub(User).new.mock!.emails.mock!.new
      get :new
    end

    it 'renders users/new' do
      get :new
      expect(response).to render_template('users/new')
    end

    it 'succeeds' do
      get :new
      expect(response).to be_success
    end
  end

  describe '#create' do
    before do
      # must use string keys because that's what Rails will pass to controller
      # (otherwise our mock expectations won't match); furthermore we have to
      # strip out keys which aren't mass-assignable, otherwise Rails will scream
      attributes = User.valid_attributes.stringify_keys.delete_if { |k,v| k == 'verified' }
      @params = { 'user' => attributes }
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
      expect(assigns[:user]).to be_kind_of(User)
    end

    context 'successful creation' do
      it 'creates a confirmation' do
        do_post
        expect(assigns[:user].emails.first.confirmations.size).to eq(1)
      end

      it 'creates a confirmation message' do
        mock.proxy(ConfirmationMailer).confirmation_message(is_a Confirmation)
        do_post
      end

      it 'delivers the confirmation message' do
        mock(controller).deliver is_a(ActionMailer::MessageDelivery)
        do_post
      end

      it 'redirects to /dashboard' do
        do_post
        expect(response).to redirect_to('/dashboard')
      end

      it 'logs in automatically' do
        do_post
        user = assigns[:user]
        expect(user.session_expiry).to be > Time.now
        expect(request.env['action_dispatch.cookies']['user_id']).to eq(user.id.to_s)
        expect(request.env['action_dispatch.cookies']['session_key']).to eq(user.session_key)
      end
    end

    context 'failed creation' do
      context 'due to invalid User record' do
        before do
          @params['user']['display_name'] = nil
          do_post
        end

        it 'shows a flash' do
          expect(flash[:error]).to match(/failed to create/i)
        end

        it 'renders users/new' do
          expect(response).to render_template('users/new')
        end
      end

      context 'due to invalid Email record' do
        before do
          @params['user']['email'] = nil
          do_post
        end

        it 'shows a flash' do
          expect(flash[:error]).to match(/failed to create/i)
        end

        it 'renders users/new' do
          expect(response).to render_template('users/new')
        end
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
      expect(assigns[:user]).to eq(user)
    end

    it 'renders users/show' do
      do_get
      expect(response).to render_template('users/show')
    end

    it 'succeeds' do
      do_get
      expect(response).to be_success
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
        expect(assigns[:user]).to eq(user)
      end

      it 'renders users/edit' do
        do_request
        expect(response).to render_template('users/edit')
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
      end
    end

    context 'as an admin user' do
      before do
        log_in_as_admin
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
      end
    end

    context 'as a different user' do
      before do
        log_in_as User.make!
      end

      it 'shows a flash' do
        do_request
        expect(flash[:notice]).to match(/not allowed to edit this user/)
      end

      it 'redirects to user#show' do
        do_request
        expect(response).to redirect_to(user)
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

      it 'updates attributes' do
        stub(User).find_with_param!(user.to_param) { user }
        mock(user).update_attributes @params
        do_request
      end

      it 'shows a flash' do
        do_request
        expect(flash[:notice]).to match(/successfully updated/i)
      end

      it 'redirects to #show' do
        do_request
        expect(response).to redirect_to(user.reload)
      end

      context 'failed update' do
        before do
          stub(User).find_with_param!(user.to_param) { user }
          stub(user).update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/update failed/i)
        end

        it 'renders users/edit' do
          do_request
          expect(response).to render_template('users/edit')
        end
      end
    end
  end
end
