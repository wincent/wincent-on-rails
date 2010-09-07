require 'spec_helper'

describe 'searches/_post' do
  before do
    @post           = Post.make!
    @result_number  = 47
  end

  def do_render
    render 'searches/post', :model => @post, :result_number => @result_number
  end

  it 'shows the result number' do
    do_render
    rendered.should contain(@result_number.to_s)
  end

  it 'uses the post title as link text' do
    do_render
    rendered.should have_selector('a', :content => @post.title)
  end

  # was a bug
  it 'escapes HTML special characters in the post title' do
    @post = Post.make! :title => '<em>foo</em>'
    do_render
    rendered.should match('&lt;em&gt;foo&lt;/em&gt;')
    rendered.should_not have_selector('em', :content => 'foo')
  end

  it 'links to the post' do
    do_render
    rendered.should have_selector('a', :href => post_path(@post))
  end

  it 'shows the timeinfo for the post' do
    mock(view).timeinfo(@post)
    do_render
  end

  it 'gets the post excerpt' do
    mock(@post).excerpt
    do_render
  end

  it 'truncates the post excerpt to 240 characters' do
    mock(view).truncate(@post.excerpt, :length => 240, :safe => true)
    do_render
  end

  it 'passes the truncated post excerpt through the wikitext translator' do
    stub(view).truncate { mock('excerpt').w :base_heading_level => 2 }
    do_render
  end
end
