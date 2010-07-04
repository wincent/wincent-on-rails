require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ArticlesController do
  describe 'routing' do
    before do
      # we use an article with "tricky" id (containing a period, which is
      # usually a format separator) to test the routes
      @article = Article.make! :title => 'Rails 3.0 upgrade notes'
    end

    example 'GET /wiki' do
      get('/wiki').should   map_to({ :controller => 'articles', :action => 'index' })
      get('/wiki').should map_from({ :controller => 'articles', :action => 'index' })
      articles_path.should == '/wiki'
    end

    example 'GET /wiki/page/2' do
      get('/wiki/page/2').should map_to(:controller => 'articles', :action => 'index', :page => '2')
      paginated_articles_path(:page => 2).should == '/wiki/page/2'
    end

    example 'GET /wiki/new' do
      get('/wiki/new').should   map_to({ :controller => 'articles', :action => 'new' })
      get('/wiki/new').should map_from({ :controller => 'articles', :action => 'new' })
      new_article_path.should == '/wiki/new'
    end

    example 'GET /wiki/Rails_3.0_upgrade_notes' do
      get('/wiki/Rails_3.0_upgrade_notes').should   map_to({ :controller => 'articles', :action => 'show', :id => 'Rails_3.0_upgrade_notes' })
      get('/wiki/Rails_3.0_upgrade_notes').should map_from({ :controller => 'articles', :action => 'show', :id => 'Rails_3.0_upgrade_notes' })
      article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes'
    end

    example 'GET /wiki/Rails_3.0_upgrade_notes/edit' do
      get('/wiki/Rails_3.0_upgrade_notes/edit').should   map_to({ :controller => 'articles', :action => 'edit', :id => 'Rails_3.0_upgrade_notes' })
      get('/wiki/Rails_3.0_upgrade_notes/edit').should map_from({ :controller => 'articles', :action => 'edit', :id => 'Rails_3.0_upgrade_notes' })
      edit_article_path(@article).should == '/wiki/Rails_3.0_upgrade_notes/edit'
    end

    example 'PUT /wiki/Rails_3.0_upgrade_notes' do
      put('/wiki/Rails_3.0_upgrade_notes').should   map_to({ :controller => 'articles', :action => 'update', :id => 'Rails_3.0_upgrade_notes' })
      put('/wiki/Rails_3.0_upgrade_notes').should map_from({ :controller => 'articles', :action => 'update', :id => 'Rails_3.0_upgrade_notes' })
    end

    example 'DELETE /wiki/Rails_3.0_upgrade_notes' do
      delete('/wiki/Rails_3.0_upgrade_notes').should   map_to({ :controller => 'articles', :action => 'destroy', :id => 'Rails_3.0_upgrade_notes' })
      delete('/wiki/Rails_3.0_upgrade_notes').should map_from({ :controller => 'articles', :action => 'destroy', :id => 'Rails_3.0_upgrade_notes' })
    end

    example 'POST /wiki' do
      post('/wiki').should   map_to({ :controller => 'articles', :action => 'create' })
      post('/wiki').should map_from({ :controller => 'articles', :action => 'create' })
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'articles', :action => 'index', :protocol => 'https' } from GET /wiki" do
      params_from(:get, "/wiki").should == {:controller => "articles", :action => "index", :protocol => 'https'}
    end

    # Rails 2.3.0 RC1 BUG: trailing slash on resources declared using ":as" raises routing error
    # See: http://rails.lighthouseapp.com:80/projects/8994/tickets/2039
    it "should generate params { :controller => 'articles', :action => 'index', :protocol => 'https' } from GET /wiki/" do
      params_from(:get, '/wiki/').should == {:controller => "articles", :action => "index", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', :action => 'new', :protocol => 'https' } from GET /wiki/new" do
      params_from(:get, "/wiki/new").should == {:controller => "articles", :action => "new", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', :action => 'create', :protocol => 'https' } from POST /wiki" do
      params_from(:post, "/wiki").should == {:controller => "articles", :action => "create", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', :action => 'show', :id => 'foo', :protocol => 'https' } from GET /wiki/foo" do
      params_from(:get, "/wiki/foo").should == {:controller => "articles", :action => "show", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', :action => 'edit', :id => 'foo', :protocol => 'https' } from GET /wiki/foo/edit" do
      params_from(:get, "/wiki/foo/edit").should == {:controller => "articles", :action => "edit", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', :action => 'update', :id => 'foo', :protocol => 'https' } from PUT /wiki/foo" do
      params_from(:put, "/wiki/foo").should == {:controller => "articles", :action => "update", :id => "foo", :protocol => 'https'}
    end

    it "should generate params { :controller => 'articles', :action => 'destroy', :id => 'foo', :protocol => 'https' } from DELETE /wiki/foo" do
      params_from(:delete, "/wiki/foo").should == {:controller => "articles", :action => "destroy", :id => "foo", :protocol => 'https'}
    end

    # test index pagination
    it "should generate params { :controller => 'articles', :action => 'index', :page => '2', :protocol => 'https' } from GET /wiki/page/2" do
      params_from(:get, '/wiki/page/2').should == {:controller => 'articles', :action => 'index', :page => '2', :protocol => 'https'}
    end

    # note how we can still have an article named "page" if we want
    it "should generate params { :controller => 'articles', :action => 'show', :if => 'page', :protocol => 'https' } from GET /wiki/page" do
      params_from(:get, '/wiki/page').should == {:controller => 'articles', :action => 'show', :id => 'page', :protocol => 'https'}
    end

    # see: https://wincent.com/issues/1410
    it 'should handle comment creation on articles with periods in the title' do
      expected = {  :controller => 'comments',
                    :action => 'create',
                    :article_id => 'foo.bar',
                    :protocol => 'https' }
      params_from(:post, '/wiki/foo.bar/comments').should == expected
    end

  # same bug: requirements (in this case the protocol) don't trickle down when
  # using nested routes
    it 'should handle comment creation on articles' do
      expected = {  :controller => 'comments',
                    :action => 'create',
                    :article_id => 'foo',
                    :protocol => 'https' }
      params_from(:post, '/wiki/foo/comments').should == expected
    end
  end
end
