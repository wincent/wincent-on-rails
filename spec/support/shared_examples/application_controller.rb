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

# not testing ActionController here; just testing that it was set-up correctly
shared_examples_for 'ApplicationController parameter filtering' do
  # BUG: this is no longer really a shared example as there is no need to run
  # it for each controller
  it 'should filter out the "passphrase" parameter' do
    Rails.application.config.filter_parameters.include?(:passphrase).should be_true
  end
end
