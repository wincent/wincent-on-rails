require File.dirname(__FILE__) + '/../spec_helper'

describe ResetsController do
  describe "handling GET /resets" do

    before(:each) do
      @reset = mock_model(Reset)
      Reset.stub!(:find).and_return([@reset])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all resets" do
      Reset.should_receive(:find).with(:all).and_return([@reset])
      do_get
    end
  
    it "should assign the found resets for the view" do
      do_get
      assigns[:resets].should == [@reset]
    end
  end

  describe "handling GET /resets.xml" do

    before(:each) do
      @reset = mock_model(Reset, :to_xml => "XML")
      Reset.stub!(:find).and_return(@reset)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all resets" do
      Reset.should_receive(:find).with(:all).and_return([@reset])
      do_get
    end
  
    it "should render the found resets as xml" do
      @reset.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /resets/1" do

    before(:each) do
      @reset = mock_model(Reset)
      Reset.stub!(:find).and_return(@reset)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the reset requested" do
      Reset.should_receive(:find).with("1").and_return(@reset)
      do_get
    end
  
    it "should assign the found reset for the view" do
      do_get
      assigns[:reset].should equal(@reset)
    end
  end

  describe "handling GET /resets/1.xml" do

    before(:each) do
      @reset = mock_model(Reset, :to_xml => "XML")
      Reset.stub!(:find).and_return(@reset)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the reset requested" do
      Reset.should_receive(:find).with("1").and_return(@reset)
      do_get
    end
  
    it "should render the found reset as xml" do
      @reset.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /resets/new" do

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

  describe "handling GET /resets/1/edit" do

    before(:each) do
      @reset = mock_model(Reset)
      Reset.stub!(:find).and_return(@reset)
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

  describe "handling POST /resets" do

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
        response.should redirect_to(reset_url("1"))
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

  describe "handling PUT /resets/1" do

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
        response.should redirect_to(reset_url("1"))
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

  describe "handling DELETE /resets/1" do

    before(:each) do
      @reset = mock_model(Reset, :destroy => true)
      Reset.stub!(:find).and_return(@reset)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the reset requested" do
      Reset.should_receive(:find).with("1").and_return(@reset)
      do_delete
    end
  
    it "should call destroy on the found reset" do
      @reset.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the resets list" do
      do_delete
      response.should redirect_to(resets_url)
    end
  end
end