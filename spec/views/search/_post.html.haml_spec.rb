require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_post' do
  before do
    @post           = create_post
    @result_number  = 47
    template.stub!(:model).and_return(@post)
    template.stub!(:result_number).and_return(@result_number)
  end

  def do_render
    render '/search/_post'
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the post title as link text' do
    do_render
    response.should have_tag('a', @post.title)
  end

  it 'should link to the post' do
    do_render
    response.should have_tag('a[href=?]', blog_path(@post))
  end

  it 'should show the timeinfo for the post' do
    template.should_receive(:timeinfo).with(@post)
    do_render
  end

  it 'should get the post excerpt' do
    @post.should_receive(:excerpt).and_return('foo')
    do_render
  end

  it 'should truncate the post excerpt to 240 characters' do
    template.should_receive(:truncate).with(@post.excerpt, 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated post excerpt through the wikitext translator' do
    excerpt = 'foo'
    excerpt.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(excerpt)
    do_render
  end

  it 'should use the preserve helper to make Haml mangle the excerpt a little bit less' do
    excerpt = 'foo'
    excerpt.stub!(:w).and_return('foo')
    template.stub!(:truncate).and_return(excerpt)
    template.should_receive(:preserve).with(excerpt)
    do_render
  end
end
