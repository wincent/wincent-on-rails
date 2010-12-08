require 'spec_helper'

describe HeartbeatController do
  it_should_behave_like 'ApplicationController subclass'

  it 'suppresses logging' do
    controller.logger.should be_nil
  end

  describe 'GET /heartbeat/ping' do
    it 'succeeds' do
      get :ping
      response.should be_success
    end

    it 'hits the database' do
      mock(Tag).first
      get :ping
    end

    it 'assigns the found tag for the view' do
      @tag = Tag.make!
      get :ping
      assigns[:tag].should == @tag
    end

    it 'creates a new tag if none in database' do
      get :ping
      assigns[:tag].should be_kind_of(Tag)
      assigns[:tag].should be_new_record
    end

    it 'renders the ping template' do
      get :ping
      response.should render_template('ping')
    end
  end
end
