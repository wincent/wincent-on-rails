require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AttachmentsController do
  describe "GET 'new'" do
    def do_get admin = false
      login_as_admin if admin
      get 'new', :protocol => 'https'
    end

    it 'should be successful' do
      do_get :as_admin
      response.should be_success
    end

    it 'should redirect non-admin users' do
      do_get
      response.should redirect_to(login_path)
    end
  end
end
