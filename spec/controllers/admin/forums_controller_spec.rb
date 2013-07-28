require 'spec_helper'

describe Admin::ForumsController do
  describe '#index' do
    def do_request
      get :index
    end

    it_has_behavior 'require_admin'

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
      @forum = Forum.make!
    end

    def do_request
      get :show, :id => @forum.id, :format => :js
    end

    it_has_behavior 'require_admin (non-HTML)'

    context 'as admin' do
      before do
        log_in_as_admin
      end

      it 'finds the forum' do
        mock.proxy(Forum).find(@forum.id.to_s)
        do_request
      end

      it 'assigns found forum' do
        do_request
        assigns[:forum].should == @forum
      end

      it 'renders as JSON' do
        stub(Forum).find.mock(@forum).to_json(anything)
        do_request
      end

      it 'includes only name, description and position' do
        do_request
        json = JSON.parse(response.body)
        json['forum'].should == {
          'name'        => @forum.name,
          'description' => nil,
          'position'    => 0,
        }
      end
    end
  end

  describe '#update.js' do
    before do
      @forum = Forum.make!
    end

    def do_request
      put :update, :id => @forum.id, :forum => { :description => 'foo' }, :format => :js
    end

    it_has_behavior 'require_admin (non-HTML)'

    context 'as admin' do
      before do
        log_in_as_admin
      end

      it 'finds the forum' do
        mock.proxy(Forum).find(@forum.id.to_s)
        do_request
      end

      it 'assigns found forum' do
        do_request
        assigns[:forum].should == @forum
      end

      it 'updates the forum attributes' do
        do_request
        @forum.reload.description.should == 'foo'
      end

      it 'redirects to /admin/forums#show' do
        do_request
        response.should redirect_to("/admin/forums/#{@forum.id}")
      end

      context 'with invalid attributes' do
        before do
          stub(Forum).find.stub(@forum).update_attributes(anything) { false }
          do_request
        end

        it 'returns status 422' do
          response.status.should == 422
        end

        it 'renders failure text' do
          response.body.should match(/update failed/i)
        end
      end
    end
  end
end
