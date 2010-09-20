require 'spec_helper'

describe ForumsController do
  describe '#edit' do
    let(:forum) { Forum.make! }

    def do_request
      get :edit, :id => forum.to_param
    end

    it_has_behavior 'require_admin'

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the forum' do
        do_request
        assigns[:forum].should == forum
      end

      it 'renders forums/edit' do
        do_request
        response.should render_template('forums/edit')
      end

      it 'succeeds' do
        do_request
        response.should be_success
      end
    end
  end

  describe '#update' do
    let(:forum) { Forum.make! }
    let(:attributes) { { 'name' => 'foo', 'permalink' => 'bar' } }

    def do_request
      put :update, :id => forum.to_param, :forum => attributes
    end

    it_has_behavior 'require_admin'

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the forum' do
        do_request
        assigns[:forum].should == forum
      end

      it 'updates the attributes' do
        do_request
        assigns[:forum].name.should == 'foo'
        assigns[:forum].permalink.should == 'bar'
      end

      it 'shows a flash' do
        do_request
        flash[:notice].should =~ /successfully updated/i
      end

      it 'redirects to #show' do
        do_request
        response.should redirect_to('/forums/bar')
      end

      context 'failed update' do
        before do
          stub(Forum).find_with_param!(forum.to_param).stub!.update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          flash[:error].should =~ /update failed/i
        end

        it 'renders forums/edit' do
          do_request
          response.should render_template('forums/edit')
        end
      end
    end
  end
end
