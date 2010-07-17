shared_examples_for 'ApplicationController protected methods' do
  context 'private methods' do
    it 'restricts access to #log_in_with_cookie' do
      lambda { controller.log_in_with_cookie }.
        should raise_error(NoMethodError, /private/)
    end

    it 'restricts access to #log_in_with_http_basic' do
      lambda { controller.log_in_with_http_basic }.
        should raise_error(NoMethodError, /private/)
    end

    it 'restricts access to #random_session_key' do
      lambda { controller.random_session_key }.
        should raise_error(NoMethodError, /private/)
    end
  end

  context 'protected methods' do
    it 'restricts access to #log_in_before' do
      lambda { controller.log_in_before }.
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

    it 'restricts access to #deliver' do
      lambda { controller.deliver }.
        should raise_error(NoMethodError, /protected/)
    end
  end
end
