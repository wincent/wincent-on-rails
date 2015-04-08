require 'spec_helper'

describe HeartbeatController do
  it_should_behave_like 'ApplicationController subclass'

  it 'suppresses logging' do
    expect(controller.logger).to be_nil
  end

  describe 'GET /heartbeat/ping' do
    it 'succeeds' do
      get :ping
      expect(response).to be_success
    end

    it 'hits the database' do
      mock(Tag).first
      get :ping
    end

    it 'assigns the found tag for the view' do
      @tag = Tag.make!
      get :ping
      expect(assigns[:tag]).to eq(@tag)
    end

    it 'creates a new tag if none in database' do
      get :ping
      expect(assigns[:tag]).to be_kind_of(Tag)
      expect(assigns[:tag]).to be_new_record
    end

    it 'renders the ping template' do
      get :ping
      expect(response).to render_template('ping')
    end
  end
end
