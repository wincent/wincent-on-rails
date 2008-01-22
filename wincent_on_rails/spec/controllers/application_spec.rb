require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController, 'protected methods', :shared => true do
  it 'should restrict access to the setup_locale method' do
    lambda { controller.setup_locale }.should raise_error(NoMethodError, /protected/)
  end

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

# not testing ActionController here; just testing that it was set-up correctly
describe ApplicationController, 'parameter filtering', :shared => true do
  before do
    @parameters = { 'safe'                    => 'public',
                    'passphrase'              => 'secret',
                    'passphrase_confirmation' => 'secret',
                    'old_passphrase'          => 'secret'}
  end

  it 'should filter out the "passphrase" parameter' do
    controller.filter_parameters(@parameters)['passphrase'].should match(/FILTERED/i)
  end

  it 'should filter out the "passphrase_confirmation" parameter' do
    controller.filter_parameters(@parameters)['passphrase_confirmation'].should match(/FILTERED/i)
  end

  it 'should filter out the "old_passphrase" parameter' do
    controller.filter_parameters(@parameters)['old_passphrase'].should match(/FILTERED/i)
  end

  it 'should pass everything else through unfiltered' do
    controller.filter_parameters(@parameters)['safe'].should == 'public'
  end
end

describe ApplicationController, :shared => true do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end
