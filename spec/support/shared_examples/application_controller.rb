shared_examples_for 'ApplicationController protected methods' do
  context 'private methods' do
    it 'restricts access to #log_in_with_cookie' do
      expect do
        controller.log_in_with_cookie
      end.to raise_error(NoMethodError, /private/)
    end

    it 'restricts access to #log_in_with_http_basic' do
      expect do
        controller.log_in_with_http_basic
      end.to raise_error(NoMethodError, /private/)
    end

    it 'restricts access to #random_session_key' do
      expect do
        controller.random_session_key
      end.to raise_error(NoMethodError, /private/)
    end
  end

  context 'protected methods' do
    it 'restricts access to #log_in_before' do
      expect do
        controller.log_in_before
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #require_admin' do
      expect do
        controller.require_admin
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #require_user' do
      expect do
        controller.require_user
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #set_current_user=' do
      expect do
        controller.set_current_user = nil
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #current_user=' do
      expect do
        controller.current_user = nil
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #current_user' do
      expect do
        controller.current_user
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #logged_in?' do
      expect do
        controller.logged_in?
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #local_request?' do
      expect do
        controller.local_request?
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #logged_in_and_verified?' do
      expect do
        controller.logged_in_and_verified?
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #admin?' do
      expect do
        controller.admin?
      end.to raise_error(NoMethodError, /protected/)
    end

    it 'restricts access to #deliver' do
      expect do
        controller.deliver
      end.to raise_error(NoMethodError, /protected/)
    end
  end
end
