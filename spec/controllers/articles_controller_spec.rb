require File.dirname(__FILE__) + '/../spec_helper'
require 'hpricot'

describe ArticlesController, 'regressions' do
  it 'should handle HTTPS URLs in the url_or_path_for_redirect method' do
    # previously only handled HTTP URLs
    title = String.random
    target = 'https://example.com/'
    create_article :title => title, :redirect => target, :body => ''
    # BUG: this "get" doesn't do what we want it to do
    # have tried 'show', :id => title, :protocol => 'https'
    #            :contoller => 'wiki', :id => title, :protocol => 'https'
    #            :controller => 'articles', :id => title, :protocol => 'https
    #            "/wiki/#{title}"
    # get_via_redirect "/wiki/#{title}" # no such method:
    pending "don't know what RSpec is doing with my get request"
    get 'show', :id => 'i hate you', :protocol => 'https'
    # i have no idea what controller/action are being called
    # (adding "raises" in articles_controller has no effect)
    # expected redirect to "https://example.com/", got redirect to "https://test.host:3002/wiki/i%20hate%20you
    response.should redirect_to(target)
  end
end

describe ArticlesController, 'GET /wiki.atom' do
  integrate_views # so that we can test layouts as well

  before do
    10.times { create_article }
  end

  def do_get
    get :index, :format => 'atom', :protocol => 'https'
  end

  # make sure we don't get bitten by bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom when there are no articles' do
    pending unless can_validate_feeds?
    Article.destroy_all
    do_get
    response.body.should be_valid_atom
  end

  it 'should produce valid atom when there are multiple articles' do
    pending unless can_validate_feeds?
    do_get
    response.body.should be_valid_atom
  end

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  it 'should produce entry links to HTML-formatted records' do
    do_get
    doc = Hpricot.XML(response.body)
    (doc/:entry).collect do |entry|
      (entry/:link).first[:href].each do |href|
        # make sure links are /wiki/foo, not /wiki/foo.atom
        href.should_not =~ %r{\.html\z}
      end
    end
  end
end

describe ArticlesController, 'GET /wiki/:title.atom' do
  integrate_views # so that we can test layouts as well

  before do
    @article = create_article :title => 'foo bar baz'
  end

  def do_get
    get :show, :id => 'foo_bar_baz', :format => 'atom', :protocol => 'https'
  end

  # guard against bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom when there are no comments' do
    pending unless can_validate_feeds?
    do_get
    response.body.should be_valid_atom
  end

  it 'should produce valid atom when there are multiple comments' do
    pending unless can_validate_feeds?
    10.times { create_comment :commentable => @article }
    do_get
    response.body.should be_valid_atom
  end
end

=begin
describe ArticlesController do
  describe 'GET /wiki/new' do
    before do
      @article = mock_model Article
      Article.stub!(:new).and_return(@article)
    end

    def do_get
      #get '/articles/new'
      get '/wiki/new' # this doesn't work either, nor does 'new', nor :new
      # I suspect it's because the controller is _articles_ and the route is _wiki_
      # so rspec is trying to hit "/articles/new" when we ask for :new
      # it's probably trying to hit "/articles/wiki/new" when we ask for "/wiki/new"
    end

    it 'should succeed' do
      do_get
      response.should be_success
    end

    it 'should create a new article' do
      Article.should_receive(:new).and_return(@article)
      do_get
    end

    it 'should not save the new article' do
      @article.should_not_receive(:save)
      do_get
    end

    it 'should assign the new article for the view' do
      do_get
      assigns[:article].should = @article
    end

    it 'should render the new template' do
      do_get
      response.should render_template('new')
    end
  end
end
=end

<<-DISABLED
describe ArticlesController do
  describe "handling GET /articles" do

    before(:each) do
      @article = mock_model(Article)
      Article.stub!(:find).and_return([@article])
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
  
    it "should find all articles" do
      Article.should_receive(:find).with(:all).and_return([@article])
      do_get
    end
  
    it "should assign the found articles for the view" do
      do_get
      assigns[:articles].should == [@article]
    end
  end

  describe "handling GET /articles.xml" do

    before(:each) do
      @article = mock_model(Article, :to_xml => "XML")
      Article.stub!(:find).and_return(@article)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all articles" do
      Article.should_receive(:find).with(:all).and_return([@article])
      do_get
    end
  
    it "should render the found articles as xml" do
      @article.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /articles/1" do

    before(:each) do
      @article = mock_model(Article)
      Article.stub!(:find).and_return(@article)
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
  
    it "should find the article requested" do
      Article.should_receive(:find).with("1").and_return(@article)
      do_get
    end
  
    it "should assign the found article for the view" do
      do_get
      assigns[:article].should equal(@article)
    end
  end

  describe "handling GET /articles/1.xml" do

    before(:each) do
      @article = mock_model(Article, :to_xml => "XML")
      Article.stub!(:find).and_return(@article)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the article requested" do
      Article.should_receive(:find).with("1").and_return(@article)
      do_get
    end
  
    it "should render the found article as xml" do
      @article.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /articles/new" do

    before(:each) do
      @article = mock_model(Article)
      Article.stub!(:new).and_return(@article)
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
  
    it "should create an new article" do
      Article.should_receive(:new).and_return(@article)
      do_get
    end
  
    it "should not save the new article" do
      @article.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new article for the view" do
      do_get
      assigns[:article].should equal(@article)
    end
  end

  describe "handling GET /articles/1/edit" do

    before(:each) do
      @article = mock_model(Article)
      Article.stub!(:find).and_return(@article)
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
  
    it "should find the article requested" do
      Article.should_receive(:find).and_return(@article)
      do_get
    end
  
    it "should assign the found Article for the view" do
      do_get
      assigns[:article].should equal(@article)
    end
  end

  describe "handling POST /articles" do

    before(:each) do
      @article = mock_model(Article, :to_param => "1")
      Article.stub!(:new).and_return(@article)
    end
    
    describe "with successful save" do
  
      def do_post
        @article.should_receive(:save).and_return(true)
        post :create, :article => {}
      end
  
      it "should create a new article" do
        Article.should_receive(:new).with({}).and_return(@article)
        do_post
      end

      it "should redirect to the new article" do
        do_post
        response.should redirect_to(article_path("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @article.should_receive(:save).and_return(false)
        post :create, :article => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /articles/1" do

    before(:each) do
      @article = mock_model(Article, :to_param => "1")
      Article.stub!(:find).and_return(@article)
    end
    
    describe "with successful update" do

      def do_put
        @article.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the article requested" do
        Article.should_receive(:find).with("1").and_return(@article)
        do_put
      end

      it "should update the found article" do
        do_put
        assigns(:article).should equal(@article)
      end

      it "should assign the found article for the view" do
        do_put
        assigns(:article).should equal(@article)
      end

      it "should redirect to the article" do
        do_put
        response.should redirect_to(article_path("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @article.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /articles/1" do

    before(:each) do
      @article = mock_model(Article, :destroy => true)
      Article.stub!(:find).and_return(@article)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the article requested" do
      Article.should_receive(:find).with("1").and_return(@article)
      do_delete
    end
  
    it "should call destroy on the found article" do
      @article.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the articles list" do
      do_delete
      response.should redirect_to(articles_path)
    end
  end
end
DISABLED
