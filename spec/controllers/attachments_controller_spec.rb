require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AttachmentsController do
  describe "GET 'new'" do
    it 'should be successful' do
      get 'new', :protocol => 'https'
      response.should be_success
    end
  end
end
