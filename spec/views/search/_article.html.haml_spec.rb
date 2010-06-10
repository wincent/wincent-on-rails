require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_article' do
  before do
    @article        = create_article
    @result_number  = 47
  end

  def do_render
    render :partial => '/search/article', :locals => { :model => @article, :result_number => @result_number }
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the article title as link text' do
    do_render
    response.should have_tag('a', @article.title)
  end

  # was a bug
  it 'should escape HTML special characters in the article title' do
    # we don't put </em> in the title because slashes are not allowed
    @article = create_article :title => '<em>foo'
    do_render
    response.should_not have_text(%r{<em>foo})
  end

  it 'should link to the article' do
    do_render
    response.should have_tag('a[href=?]', article_path(@article))
  end

  it 'should show the timeinfo for the article' do
    template.should_receive(:timeinfo).with(@article)
    do_render
  end

  it 'should get the article body' do
    @article.should_receive(:body).and_return('foo')
    do_render
  end

  it 'should truncate the article body to 240 characters' do
    template.should_receive(:truncate).with(@article.body, :length => 240, :safe => true).and_return('foo')
    do_render
  end

  it 'should pass the truncated article body through the wikitext translator' do
    body = 'foo'
    body.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(body)
    do_render
  end
end
