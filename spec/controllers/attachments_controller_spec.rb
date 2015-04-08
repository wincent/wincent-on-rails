require 'spec_helper'

describe AttachmentsController do
  describe "GET 'new'" do
    def do_get admin = false
      log_in_as_admin if admin
      get 'new', :protocol => 'https'
    end

    it 'should be successful' do
      do_get :as_admin
      expect(response).to be_success
    end

    it 'should redirect non-admin users' do
      do_get
      expect(response).to redirect_to(login_path)
    end
  end
end
