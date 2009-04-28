require File.dirname(__FILE__) + '/../spec_helper'

=begin
describe ResetsController do
  describe '"index" action' do
    it 'should not respond' do
      controller.should_not respond_to(:index)
    end
  end

  describe '"show" action' do
    it 'should not respond' do
      controller.should_not respond_to(:show)
    end
  end

  describe '"new" action' do
    before(:each) do
      @reset = mock_model(Reset)
      Reset.stub!(:new).and_return(@reset)
    end

    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should create an new reset" do
      Reset.should_receive(:new).and_return(@reset)
      do_get
    end

    it "should not save the new reset" do
      @reset.should_not_receive(:save)
      do_get
    end

    it "should assign the new reset for the view" do
      do_get
      assigns[:reset].should equal(@reset)
    end
  end

  describe '"edit" action' do
    before(:each) do
      @reset = mock_model(Reset)
      @user = mock_model(User)
      Reset.stub!(:find_by_secret).and_return(@reset)
      @reset.stub!(:user).and_return(@user)
    end

    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should find the reset requested" do
      Reset.should_receive(:find).and_return(@reset)
      do_get
    end

    it "should assign the found Reset for the view" do
      do_get
      assigns[:reset].should equal(@reset)
    end
  end

  describe '"create" action' do
    before(:each) do
      @reset = mock_model(Reset, :to_param => "1")
      Reset.stub!(:new).and_return(@reset)
    end

    describe "with successful save" do
      def do_post
        @reset.should_receive(:save).and_return(true)
        post :create, :reset => {}
      end

      it "should create a new reset" do
        Reset.should_receive(:new).with({}).and_return(@reset)
        do_post
      end

      it "should redirect to the new reset" do
        do_post
        response.should redirect_to(reset_path("1"))
      end
    end

    describe "with failed save" do
      def do_post
        @reset.should_receive(:save).and_return(false)
        post :create, :reset => {}
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
    end
  end

  describe '"update" action' do
    before(:each) do
      @reset = mock_model(Reset, :to_param => "1")
      Reset.stub!(:find).and_return(@reset)
    end

    describe "with successful update" do
      def do_put
        @reset.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the reset requested" do
        Reset.should_receive(:find).with("1").and_return(@reset)
        do_put
      end

      it "should update the found reset" do
        do_put
        assigns(:reset).should equal(@reset)
      end

      it "should assign the found reset for the view" do
        do_put
        assigns(:reset).should equal(@reset)
      end

      it "should redirect to the reset" do
        do_put
        response.should redirect_to(reset_path("1"))
      end
    end

    describe "with failed update" do
      def do_put
        @reset.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end
    end
  end

  describe '"destroy" action' do
    it 'should not respond' do
      controller.should_not respond_to(:destroy)
    end
  end
end
=end
