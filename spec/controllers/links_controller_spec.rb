require 'spec_helper'

describe LinksController do
  it_has_behavior 'ApplicationController protected methods'

  describe 'show action with permalink' do
    before do
      @link = Link.make! :permalink => 'foo'
    end

    # was a bug (I'd forgotten to use the "find_link" before filter)
    it 'should find the link by the permalink' do
      mock(Link).find_by_permalink('foo') { @link }
      get :show, :id => 'foo'
    end
  end

  describe 'show action with raw id' do
    before do
      @link = Link.make!
    end

    # was a bug (I'd forgotten to use the "find_link" before filter)
    it 'should find the link by falling back to a find by id' do
      stub(Link).find_by_permalink(@link.id) { nil }  # fail on first try, but...
      mock(Link).find(@link.id) { @link }             # succeed on fallback
      get :show, :id => @link.id
    end
  end

  describe '#edit' do
    let(:link) { Link.make! }

    def do_request
      get :edit, :id => link.to_param
    end

    it_has_behavior 'require_admin'

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the link' do
        do_request
        assigns[:link].should == link
      end

      it 'renders links/edit' do
        do_request
        response.should render_template('links/edit')
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end
    end
  end

  describe '#update (HTML format)' do
    let(:link) { Link.make! }
    let(:attributes) { { 'uri' => 'http://example.com/', 'permalink' => 'foo' } }

    def do_request
      put :update, :id => link.to_param, :link => attributes
    end

    it_has_behavior 'require_admin'

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the link' do
        do_request
        assigns[:link].should == link
      end

      it 'updates the attributes' do
        do_request
        assigns[:link].uri.should == 'http://example.com/'
        assigns[:link].permalink.should == 'foo'
      end

      it 'shows a flash' do
        do_request
        cookie_flash[:notice].should =~ /successfully updated/i
      end

      it 'redirects to /links' do
        do_request
        response.should redirect_to('/links')
      end

      context 'failed updated' do
        before do
          stub(Link).find_by_permalink(link.to_param).stub!.update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          cookie_flash[:error].should =~ /update failed/i
        end

        it 'renders links/edit' do
          do_request
          response.should render_template('links/edit')
        end
      end
    end
  end
end
