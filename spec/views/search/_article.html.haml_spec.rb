require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_article' do
  before do
    @article        = create_article
    @result_number  = 47
    template.stub!(:model).and_return(@article)
    template.stub!(:result_number).and_return(@result_number)
  end

  def do_render
    render '/search/_article'
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the article title as link text' do
    do_render
    response.should have_tag('a', @article.title)
  end

  it 'should link to the article' do
    do_render
    response.should have_tag('a[href=?]', wiki_path(@article))
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
    template.should_receive(:truncate).with(@article.body, 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated article body through the wikitext translator' do
    body = 'foo'
    body.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(body)
    do_render
  end
end
