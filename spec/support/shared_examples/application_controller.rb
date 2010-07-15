shared_examples_for 'ApplicationController protected methods' do
  context 'private methods' do
    it 'restricts access to #login_with_cookie' do
      lambda { controller.login_with_cookie }.
        should raise_error(NoMethodError, /private/)
    end

    it 'restricts access to #login_with_http_basic' do
      lambda { controller.login_with_http_basic }.
        should raise_error(NoMethodError, /private/)
    end

    it 'restricts access to #random_session_key' do
      lambda { controller.random_session_key }.
        should raise_error(NoMethodError, /private/)
    end
  end

  context 'protected methods' do
    it 'restricts access to #login_before' do
      lambda { controller.login_before }.
        should raise_error(NoMethodError, /protected/)
    end
    it 'restricts access to #require_admin' do
      lambda { controller.require_admin }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #require_user' do
      lambda { controller.require_user }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #set_current_user=' do
      lambda { controller.set_current_user = nil }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #current_user=' do
      lambda { controller.current_user = nil }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #current_user' do
      lambda { controller.current_user }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #logged_in?' do
      lambda { controller.logged_in? }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #local_request?' do
      lambda { controller.local_request? }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #logged_in_and_verified?' do
      lambda { controller.logged_in_and_verified? }.
        should raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #admin?' do
      lambda { controller.admin? }.
        should raise_error(NoMethodError, /protected/)
    end
  end
end

# not testing ActionController here; just testing that it was set-up correctly
shared_examples_for 'ApplicationController parameter filtering' do
  # BUG: this is no longer really a shared example as there is no need to run
  # it for each controller
  it 'filters out the "passphrase" parameter' do
    Rails.application.config.filter_parameters.include?(:passphrase).should be_true
  end
end
