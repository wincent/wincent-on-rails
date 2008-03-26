require File.dirname(__FILE__) + '/../spec_helper'

describe HeartbeatController do
  it 'should suppress logging' do
    controller.logger.should be_nil
  end

  describe 'GET /heartbeat/ping' do
    before do
      @tag = mock_model Tag
      Tag.stub!(:new).and_return(@tag)
    end

    def do_get
      get :ping
    end

    it 'should succeed' do
      do_get
      response.should be_success
    end

    it 'should hit the database' do
      Tag.should_receive(:find).and_return(@tag)
      do_get
    end

    it 'should assign the found tag for the view' do
      do_get
      assigns[:tag].should == @tag
    end

    it 'should render the ping template' do
      do_get
      response.should render_template('ping')
    end
  end
end
