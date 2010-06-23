require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/search/create with one page of search results' do
  before do
    assigns[:models] = @models = [@article = create_article, @issue = create_issue, @post = create_post, @topic = create_topic]
    assigns[:offset] = @offset = 15
  end

  def do_render
    render 'search/create'
  end

  it 'should include the "search" style sheet' do
    template.should_receive(:content_for).with(:css).and_yield
    template.should_receive(:stylesheet_link_tag).with('search')
    do_render
  end

  it 'should should render the article partial for article results' do
    template.should_receive :render, :partial => 'search/article', :locals => { :model => @article, :result_number => @offset + 1 }
    do_render
  end

  it 'should should render the issue partial for issue results' do
    template.should_receive :render, :partial => 'search/issue', :locals => { :model => @issue, :result_number => @offset + 2 }
    do_render
  end

  it 'should should render the post partial for post results' do
    template.should_receive :render, :partial => 'search/post', :locals => { :model => @post, :result_number => @offset + 3 }
    do_render
  end

  it 'should should render the topic partial for topic results' do
    template.should_receive :render, :partial => 'search/topic', :locals => { :model => @topic, :result_number => @offset + 4 }
    do_render
  end

  it 'should have a "search again" link' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', search_index_path
    end
  end
end

describe '/search/create with some "nil" search results' do
  # these can occur when somebody does a Model.delete
  # in that case, the model gets destroyed and no callbacks are fired
  # so the needles index doesn't get updated
  # when we try to prefetch those missing models we get nil placeholders
  before do
    assigns[:models] = [@issue = create_issue, nil, nil]
    assigns[:offset] = 0
  end

  def do_render
    render 'search/create'
  end

  it 'should should render the partial for existing results' do
    template.should_receive :render, :partial => 'search/issue', :locals => { :model => @issue, :result_number => 1 }
    do_render
  end

  it 'should not choke on the nil placeholders' do
    lambda { do_render }.should_not raise_error
  end
end


describe '/search/create with no search results' do
  before do
    assigns[:models] = []
    assigns[:offset] = 0
  end

  it 'should display "no results"' do
    render 'search/create'
    response.should have_text(/no results/i)
  end
end

describe '/search/create with multiple pages of search results' do
  before do
    models = []
    60.times { models << create_issue }
    assigns[:models] = models
    assigns[:offset] = @offset = 20
    params[:query] = 'foo'
  end

  it 'should display a "more results" form button' do
    render 'search/create'
    response.should have_tag('form[action=?]', search_index_path) do
      with_tag 'input[type=hidden][name=query][value=?]', 'foo'
      with_tag 'input[type=hidden][name=offset][value=?]', @offset + 20
      with_tag 'input[type=submit][value=?]', 'more results...'
    end
  end
end
