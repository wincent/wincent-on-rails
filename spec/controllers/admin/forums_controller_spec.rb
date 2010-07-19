require File.expand_path('../../spec_helper', File.dirname(__FILE__))

shared_examples_for 'require_admin' do
  it 'stores the original URI in the session' do
    do_request
    session[:original_uri].should_not be_blank
    session[:original_uri].should == response.request.fullpath
  end

  it 'redirects to /login' do
    do_request
    response.should redirect_to('/login')
  end

  it 'shows a flash' do
    do_request
    cookie_flash['notice'].should =~ /requires administrator privileges/
  end
end

describe Admin::ForumsController do
  describe '#index' do
    def do_request
      get :index
    end

    it_should_behave_like 'require_admin'
    # TODO: after RSpec 2.0.0.beta.18 comes out, this will become,
    # either with or without the block:
    #   it_has_behavior 'require_admin' do
    #     def do_request
    #       get :index
    #     end
    #   end

    context 'as admin' do
      before do
        @forum1 = Forum.make!
        @forum2 = Forum.make!
        log_in_as_admin
      end

      it 'finds all forums' do
        mock(Forum).all
        do_request
      end

      it 'assigns found forums' do
        do_request
        assigns[:forums] =~ [@forum1, @forum2]
      end
    end
  end
end
