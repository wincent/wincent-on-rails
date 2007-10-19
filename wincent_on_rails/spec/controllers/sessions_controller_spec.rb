require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController, 'logging in with a valid username and passphrase' do
  before do
    User.should_receive(:authenticate).and_return(default_user)
    post 'create'
  end

  it 'should flash a success notice' do
    flash[:notice].should match(/logged in/i)
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

describe SessionsController, 'logging out' do
  before do
    post 'destroy'
  end

  it 'should flash a success notice' do
    flash[:notice].should match(/logged out/i)
  end

  it 'should set the current user to nil' do
    assigns[:current_user].should == nil
  end

  it 'should redirect to the home path' do
    response.should redirect_to(home_path)
  end
end
