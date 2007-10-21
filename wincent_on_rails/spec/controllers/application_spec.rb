require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController, 'protected methods', :shared => true do
  it 'should restrict access to the login_with_session_key method' do
    lambda { controller.login_with_session_key }.should raise_error(NoMethodError, /protected/)
  end

  it 'should restrict access to the require_admin method' do
    lambda { controller.require_admin }.should raise_error(NoMethodError, /protected/)
  end

  it 'should restrict access to the require_user method' do
    lambda { controller.require_user }.should raise_error(NoMethodError, /protected/)
  end

  it 'should restrict access to the current_user= method' do
    lambda { controller.current_user = nil }.should raise_error(NoMethodError, /protected/)
  end

  it 'should restrict access to the current_user method' do
    lambda { controller.current_user }.should raise_error(NoMethodError, /protected/)
  end

  it 'should restrict access to the logged_in? method' do
    lambda { controller.logged_in? }.should raise_error(NoMethodError, /protected/)
  end

  it 'should restrict access to the admin? method' do
    lambda { controller.admin? }.should raise_error(NoMethodError, /protected/)
  end
end

describe ApplicationController, :shared => true do
  # BUG: probably harmless, currently investigating, but nesting like this causes the specs to be run twice:
  # http://rubyforge.org/pipermail/rspec-users/2007-October/003989.html
  it_should_behave_like 'ApplicationController protected methods'
end