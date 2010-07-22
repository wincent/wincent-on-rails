require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe SessionsController do
  it_has_behavior 'ApplicationController protected methods'
end

def current_user
  controller.send :current_user
end

describe SessionsController, 'logging in with a valid username and passphrase' do
  before do
    @user = User.make!
    stub(User).authenticate(anything, anything) { @user }
    post 'create', :protocol => 'https'
  end

  it 'should flash a success notice' do
    cookie_flash['notice'].should match(/logged in/i)
  end

  it 'should set the current user' do
    current_user.should == @user
  end

  it 'should redirect to the user dashboard' do
    response.should redirect_to(dashboard_path)
  end
end

describe SessionsController, 'logging in with an invalid username or passphrase' do
  before do
    stub(User).authenticate(anything, anything) { nil }
    post 'create', :protocol => 'https'
  end

  it 'should flash an error' do
    cookie_flash['error'].should match(/invalid/i)
  end

  it 'should render the new session (login) form again' do
    response.should render_template('new')
  end
end

describe SessionsController, 'logging out when previously logged in' do
  before do
    log_in_as User.make!
    post 'destroy', :protocol => 'https'
  end

  it 'should flash a success notice' do
    cookie_flash['notice'].should match(/logged out/i)
  end

  it 'should set the current user to nil' do
    current_user.should == nil
  end

  it 'should redirect to the home path' do
    response.should redirect_to(root_path)
  end
end

describe SessionsController, 'logging out when not previously logged in' do
  before do
    post 'destroy', :protocol => 'https'
  end

  it 'should flash an error' do
    cookie_flash['error'].should match(/Can't log out/i)
  end

  it 'should redirect to the home path' do
    response.should redirect_to(root_path)
  end
end

describe SessionsController, 'redirecting after login' do
  before do
    @user = User.make!
    stub(User).authenticate(anything, anything) { @user }
  end

  it 'should redirect to the user dashboard if no original uri supplied' do
    post 'create', :protocol => 'https'
    response.should redirect_to(dashboard_path)
  end

  it 'should redirect to if original uri supplied via session' do
    session[:original_uri] = '/comments'
    post 'create', :protocol => 'https'
    response.should redirect_to(comments_path)
  end

  it 'should redirect to if original uri supplied via params' do
    post 'create', :original_uri => '/comments', :protocol => 'https'
    response.should redirect_to(comments_path)
  end

  # was a bug were failing because even blank "original_uri" would redirect (to the root rather than the dashboard)
  it 'should redirect to the user dashboard if original uri is blank' do
    session[:original_uri] = ''
    post 'create', :protocol => 'https'
    response.should redirect_to(dashboard_path)
  end
end
