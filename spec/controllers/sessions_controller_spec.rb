require 'spec_helper'

describe SessionsController do
  it_should_behave_like 'ApplicationController subclass'

  def current_user
    controller.send :current_user
  end

  describe 'logging in with a valid username and passphrase' do
    before do
      @user = User.make!
      stub(User).authenticate(anything, anything) { @user }
      post 'create', protocol: 'https'
    end

    it 'should flash a success notice' do
      expect(flash[:notice]).to match(/logged in/i)
    end

    it 'should set the current user' do
      expect(current_user).to eq(@user)
    end
  end

  describe 'logging in with an invalid username or passphrase' do
    before do
      stub(User).authenticate(anything, anything) { nil }
      post 'create', protocol: 'https'
    end

    it 'should flash an error' do
      expect(flash[:error]).to match(/invalid/i)
    end

    it 'should render the new session (login) form again' do
      expect(response).to render_template('new')
    end
  end

  describe 'logging out when previously logged in' do
    before do
      log_in_as User.make!
      post 'destroy', protocol: 'https'
    end

    it 'should flash a success notice' do
      expect(flash[:notice]).to match(/logged out/i)
    end

    it 'should set the current user to nil' do
      expect(current_user).to eq(nil)
    end

    it 'should redirect to the home path' do
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'logging out when not previously logged in' do
    before do
      post 'destroy', protocol: 'https'
    end

    it 'should flash an error' do
      expect(flash[:error]).to match(/Can't log out/i)
    end

    it 'should redirect to the home path' do
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'redirecting after login' do
    before do
      @user = User.make!
      stub(User).authenticate(anything, anything) { @user }
    end

    it 'redirects to the original URI supplied via session' do
      session[:original_uri] = '/comments'
      post 'create', protocol: 'https'
      expect(response).to redirect_to(comments_path)
    end

    it 'redirects to the original URI supplied via params' do
      post 'create', session: { original_uri: '/comments' }, protocol: 'https'
      expect(response).to redirect_to(comments_path)
    end
  end
end
