require 'spec_helper'

describe LinksController do
  it_should_behave_like 'ApplicationController subclass'

  describe 'show action with permalink' do
    before do
      @link = Link.make! :permalink => 'foo', :uri => '[[foo]]'
    end

    # was a bug (I'd forgotten to use the "find_link" before filter)
    it 'should find the link by the permalink' do
      mock(Link).find_by_permalink('foo') { @link }
      get :show, :id => 'foo'
    end

    it 'redirects to the corresponding URL' do
      get :show, :id => 'foo'
      expect(response).to redirect_to('/wiki/foo')
    end
  end

  describe 'show action with raw id' do
    before do
      @link = Link.make! :uri => '[[bar]]'
    end

    # was a bug (I'd forgotten to use the "find_link" before filter)
    it 'should find the link by falling back to a find by id' do
      stub(Link).find_by_permalink(@link.id.to_s) { nil } # fail on first try, but...
      mock(Link).find(@link.id.to_s) { @link }            # succeed on fallback
      get :show, :id => @link.id
    end

    it 'redirects to the corresponding URL' do
      get :show, :id => @link.id
      expect(response).to redirect_to('/wiki/bar')
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
        expect(assigns[:link]).to eq(link)
      end

      it 'renders links/edit' do
        do_request
        expect(response).to render_template('links/edit')
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
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
        expect(assigns[:link]).to eq(link)
      end

      it 'updates the attributes' do
        do_request
        expect(assigns[:link].uri).to eq('http://example.com/')
        expect(assigns[:link].permalink).to eq('foo')
      end

      it 'shows a flash' do
        do_request
        expect(flash[:notice]).to match(/successfully updated/i)
      end

      it 'redirects to /links' do
        do_request
        expect(response).to redirect_to('/links')
      end

      context 'failed updated' do
        before do
          stub(Link).find_by_permalink(link.to_param).stub!.update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/update failed/i)
        end

        it 'renders links/edit' do
          do_request
          expect(response).to render_template('links/edit')
        end
      end
    end
  end
end
