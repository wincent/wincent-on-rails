require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_spec'

describe SessionsController do
  it_should_behave_like 'ApplicationController'
end

def login_as user
  controller.instance_eval { @current_user = user }
  controller.stub!(:login_before).and_return(nil)   # don't let the before filter clear the user again
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

  it 'should redirect to the home path' do
    response.should redirect_to(home_path)
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
    response.should redirect_to(home_path)
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
    response.should redirect_to(home_path)
  end
end
