require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'searches/create' do
  context 'with one page of search results' do
    before do
      @models = [@article = Article.make!, @issue = Issue.make!, @post = Post.make!, @topic = Topic.make!]
      @offset = 15
    end

    it 'includes breadcrumbs' do
      mock(view).breadcrumbs 'Search'
      render
    end

    it 'renders the article partial for article results' do
      stub.proxy(view).render
      mock(view).render 'searches/article', :model => @article, :result_number => @offset + 1
      render
    end

    it 'renders the issue partial for issue results' do
      stub.proxy(view).render
      mock(view).render 'searches/issue', :model => @issue, :result_number => @offset + 2
      render
    end

    it 'renders the post partial for post results' do
      stub.proxy(view).render
      mock(view).render 'searches/post', :model => @post, :result_number => @offset + 3
      render
    end

    it 'renders the topic partial for topic results' do
      stub.proxy(view).render
      mock(view).render 'searches/topic', :model => @topic, :result_number => @offset + 4
      render
    end

    it 'has a "search again" link' do
      render
      rendered.should have_selector('.links a', :href=> '/search/new')
    end
  end

  context 'with some "nil" search results' do
    # these can occur when somebody does a Model.delete
    # in that case, the model gets destroyed and no callbacks are fired
    # so the needles index doesn't get updated
    # when we try to prefetch those missing models we get nil placeholders
    before do
      @models = [@issue = Issue.make!, nil, nil]
      @offset = 0
    end

    it 'renders the partial for existing results' do
      stub.proxy(view).render
      mock(view).render 'searches/issue', :model => @issue, :result_number => 1
      render
    end

    it 'does not choke on the nil placeholders' do
      lambda { render }.should_not raise_error
    end
  end

  context 'with no search results' do
    before do
      @models = []
      @offset = 0
    end

    it 'displays "no results"' do
      render
      rendered.should contain(/no results/i)
    end
  end

  context 'with multiple pages of search results' do
    before do
      @models = Array.new(60) { Issue.make! }
      @offset = 20
      @query = 'foo'
    end

    it 'displays a "more results" form button' do
      render
      rendered.should have_selector('form', :action => '/search') do |form|
        form.should have_selector('input[type=hidden][name=offset]', :value => (@offset + 20).to_s)
        form.should have_selector('input[type=submit]', :value => 'more results...')
        form.should have_selector('input[type=hidden][name=query]', :value => 'foo')
      end
    end
  end
end
