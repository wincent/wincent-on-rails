require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_spec'

describe SessionsController do
  it_should_behave_like 'ApplicationController'
end

def current_user
  controller.send :current_user
end

describe SessionsController, 'logging in with a valid username and passphrase' do
  before do
    @user = create_user
    User.should_receive(:authenticate).and_return(@user)
    post 'create'
  end

  it 'should flash a success notice' do
    flash[:notice].should match(/logged in/i)
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
    User.should_receive(:authenticate).and_return(nil)
    post 'create'
  end

  it 'should flash an error' do
    flash[:error].should match(/invalid/i)
  end

  it 'should render the new session (login) form again' do
    response.should render_template('new')
  end
end

describe SessionsController, 'logging out when previously logged in' do
  before do
    login_as create_user
    post 'destroy'
  end

  it 'should flash a success notice' do
    flash[:notice].should match(/logged out/i)
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
    post 'destroy'
  end

  it 'should flash an error' do
    flash[:error].should match(/Can't log out/i)
  end

  it 'should redirect to the home path' do
    response.should redirect_to(root_path)
  end
end

describe SessionsController, 'redirecting after login' do
  before do
    @user = create_user
    User.should_receive(:authenticate).and_return(@user)
  end

  it 'should redirect to the user dashboard if no original uri supplied' do
    post 'create'
    response.should redirect_to(dashboard_path)
  end

  it 'should redirect to if original uri supplied via session' do
    session[:original_uri] = '/comments'
    post 'create'
    response.should redirect_to('/comments')
  end

  it 'should redirect to if original uri supplied via params' do
    post 'create', :original_uri => '/comments'
    response.should redirect_to('/comments')
  end

  # was a bug were failing because even blank "original_uri" would could a redirect (to the root rather than the dashboard)
  it 'should redirect to the user dashboard if original uri is blank' do
    session[:original_uri] = ''
    post 'create'
    response.should redirect_to(dashboard_path)
  end
end
