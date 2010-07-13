require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'searches/_article' do
  before do
    @article        = Article.make!
    @result_number  = 47
  end

  def do_render
    render 'searches/article', :model => @article, :result_number => @result_number
  end

  it 'shows the result number' do
    do_render
    rendered.should contain(@result_number.to_s)
  end

  it 'uses the article title as link text' do
    do_render
    rendered.should have_selector('a', :content => @article.title)
  end

  # was a bug
  it 'escapes HTML special characters in the article title' do
    # we don't put </em> in the title because slashes are not allowed
    @article = Article.make! :title => '<em>foo'
    do_render
    rendered.should match('&lt;em&gt;foo')
    rendered.should_not match('<em>foo')
  end

  it 'links to the article' do
    do_render
    rendered.should have_selector('a', :href => article_path(@article))
  end

  it 'shows the timeinfo for the article' do
    mock(view).timeinfo(@article)
    do_render
  end

  it 'gets the article body' do
    mock(@article).body
    do_render
  end

  it 'truncates the article body to 240 characters' do
    mock(view).truncate(@article.body, :length => 240, :safe => true)
    do_render
  end

  it 'passes the truncated article body through the wikitext translator' do
    stub(view).truncate { mock('body').w :base_heading_level => 2 }
    do_render
  end
end
