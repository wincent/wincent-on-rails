require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_post' do
  before do
    @post           = create_post
    @result_number  = 47
  end

  def do_render
    render :partial => '/search/post', :locals => { :model => @post, :result_number => @result_number }
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the post title as link text' do
    do_render
    response.should have_tag('a', @post.title)
  end

  # was a bug
  it 'should escape HTML special characters in the post title' do
    @post = create_post :title => '<em>foo</em>'
    do_render
    response.should_not have_text(%r{<em>foo</em>})
  end

  it 'should link to the post' do
    do_render
    response.should have_tag('a[href=?]', post_path(@post))
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
    template.should_receive(:truncate).with(@post.excerpt, :length => 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated post excerpt through the wikitext translator' do
    excerpt = 'foo'
    excerpt.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(excerpt)
    do_render
  end
end
