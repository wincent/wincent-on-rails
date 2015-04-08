require 'spec_helper'

describe 'search/_post' do
  before do
    @post           = Post.make!
    @result_number  = 47
  end

  def do_render
    render 'search/post', model: @post, result_number: @result_number
  end

  it 'shows the result number' do
    do_render
    expect(rendered).to have_content(@result_number.to_s)
  end

  it 'uses the post title as link text' do
    do_render
    expect(rendered).to have_link(@post.title)
  end

  # was a bug
  it 'escapes HTML special characters in the post title' do
    @post = Post.make! title: '<em>foo</em>'
    do_render
    expect(rendered).to match('&lt;em&gt;foo&lt;/em&gt;')
    expect(rendered).not_to have_css('em', text: 'foo')
  end

  it 'links to the post' do
    do_render
    expect(rendered).to have_link(@post.title, href: post_path(@post))
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
    mock(view).truncate(@post.excerpt, :length => 240)
    do_render
  end

  it 'passes the truncated post excerpt through the wikitext translator' do
    stub(view).truncate { mock('excerpt').w :base_heading_level => 2 }
    do_render
  end
end
