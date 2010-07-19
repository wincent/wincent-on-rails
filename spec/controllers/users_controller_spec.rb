require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe UsersController do
  describe '#index' do
    def do_request
      get :index
    end

    it_should_behave_like 'require_admin'

    context 'as admin' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns users' do
        2.times { User.make! } # plus 1 admin user from log_in_as_admin
        do_request
        assigns[:users].to_a.should =~ User.all
      end
    end
  end
end
