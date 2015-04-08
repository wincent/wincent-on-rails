require 'spec_helper'

describe 'search/_article' do
  before do
    @article        = Article.make!
    @result_number  = 47
  end

  def do_render
    render 'search/article', model: @article, result_number: @result_number
  end

  it 'shows the result number' do
    do_render
    expect(rendered).to have_content(@result_number.to_s)
  end

  it 'uses the article title as link text' do
    do_render
    expect(rendered).to have_link(@article.title)
  end

  # was a bug
  it 'escapes HTML special characters in the article title' do
    # we don't put </em> in the title because slashes are not allowed
    @article = Article.make! title: '<em>foo'
    do_render
    expect(rendered).to match('&lt;em&gt;foo')
    expect(rendered).not_to match('<em>foo')
  end

  it 'links to the article' do
    do_render
    expect(rendered).to have_link(@article.title, href: article_path(@article))
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
    mock(view).truncate(@article.body, length: 240)
    do_render
  end

  it 'passes the truncated article body through the wikitext translator' do
    stub(view).truncate { mock('body').w base_heading_level: 2 }
    do_render
  end
end
