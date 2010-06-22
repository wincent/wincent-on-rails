require File.dirname(__FILE__) + '/../spec_helper'

if !Rspec.world.shared_example_groups.has_key? 'ApplicationController protected methods'
  shared_examples_for 'ApplicationController protected methods' do
    it 'should restrict access to the login_with_cookie method' do
      lambda { controller.login_with_cookie }.should raise_error(NoMethodError, /protected/)
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

    it 'should restrict access to the logged_in_and_verified? method' do
      lambda { controller.logged_in_and_verified? }.should raise_error(NoMethodError, /protected/)
    end

    it 'should restrict access to the admin? method' do
      lambda { controller.admin? }.should raise_error(NoMethodError, /protected/)
    end
  end
end

if !Rspec.world.shared_example_groups.has_key? 'ApplicationController parameter filtering'
  # not testing ActionController here; just testing that it was set-up correctly
  shared_examples_for 'ApplicationController parameter filtering' do
    before do
      @parameters = { 'safe'                    => 'public',
                      'passphrase'              => 'secret',
                      'passphrase_confirmation' => 'secret',
                      'old_passphrase'          => 'secret'}
    end

    it 'should filter out the "passphrase" parameter' do
      controller.send(:filter_parameters, @parameters)['passphrase'].should match(/FILTERED/i)
    end

    it 'should filter out the "passphrase_confirmation" parameter' do
      controller.send(:filter_parameters, @parameters)['passphrase_confirmation'].should match(/FILTERED/i)
    end

    it 'should filter out the "old_passphrase" parameter' do
      controller.send(:filter_parameters, @parameters)['old_passphrase'].should match(/FILTERED/i)
    end

    it 'should pass everything else through unfiltered' do
      controller.send(:filter_parameters, @parameters)['safe'].should == 'public'
    end
  end
end
