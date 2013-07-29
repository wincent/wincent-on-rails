require 'spec_helper'

describe Admin::DashboardController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#show' do
    let(:conditions) { { awaiting_moderation: true } }
    before { log_in_as_admin }

    it 'runs the "require_admin" before filter' do
      mock(controller).require_admin
      get :show
    end

    it 'gets the count of comments awaiting moderation' do
      mock(Comment).where(conditions).mock!.count { 100 }
      get :show
      assigns[:comment_count].should == 100
    end

    it 'gets the count of issues awaiting moderation' do
      mock(Issue).where(conditions).mock!.count { 200 }
      get :show
      assigns[:issue_count].should == 200
    end

    it 'gets the count of topics awaiting moderation' do
      mock(Topic).where(conditions).mock!.count { 300 }
      get :show
      assigns[:topic_count].should == 300
    end

    it 'renders the show template' do
      get :show
      response.should render_template('show')
    end

    it 'is successful' do
      get :show
      response.should be_success
    end
  end
end
