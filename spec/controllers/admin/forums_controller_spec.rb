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

shared_examples_for 'require_admin (non-HTML)' do
  it 'returns status 403 (forbidden)' do
    do_request
    response.status.should == 403
  end

  it 'renders "forbidden" test' do
    do_request
    response.body.should match(/forbidden/i)
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

  describe '#show.js' do
    before do
      @forum = Forum.make! :permalink => 'foo'
    end

    def do_request
      get :show, :id => @forum.id, :format => :js
    end

    it_should_behave_like 'require_admin (non-HTML)'

    context 'as admin' do
      before do
        log_in_as_admin
      end

      it 'finds the forum' do
        mock.proxy(Forum).find(@forum.id)
        do_request
      end

      it 'assigns found forum' do
        do_request
        assigns[:forum].should == @forum
      end

      it 'renders as JSON' do
        stub(Forum).find(@forum.id).mock(@forum).to_json(anything)
        do_request
      end

      it 'includes only name, description and position' do
        do_request
        json = JSON.parse(response.body)
        json['forum'].should == {
          'name'        => @forum.name,
          'description' => nil,
          'position'    => 0
        }
      end
    end
  end
end
