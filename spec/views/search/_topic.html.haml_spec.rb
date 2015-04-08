require 'spec_helper'

describe 'search/_topic' do
  before do
    @topic          = Topic.make!
    @result_number  = 47
  end

  def do_render
    render 'search/topic', model: @topic, result_number: @result_number
  end

  it 'shows the result number' do
    do_render
    expect(rendered).to have_content(@result_number.to_s)
  end

  it 'uses the topic title as link text' do
    do_render
    expect(rendered).to have_link(@topic.title)
  end

  # was a bug
  it 'escapes HTML special characters in the topic summary' do
    @topic = Topic.make! title: '<em>foo</em>'
    do_render
    expect(rendered).to match('&lt;em&gt;foo&lt;/em&gt;')
    expect(rendered).not_to have_css('em', text: 'foo')
  end

  it 'links to the topic' do
    do_render
    expect(rendered).to have_link(@topic.title, href: topic_path(@topic))
  end

  it 'shows the timeinfo for the topic' do
    mock(view).timeinfo(@topic)
    do_render
  end

  it 'gets the topic body' do
    mock(@topic).body
    do_render
  end

  it 'truncates the topic body to 240 characters' do
    mock(view).truncate @topic.body, length: 240
    do_render
  end

  it 'passes the truncated topic body through the wikitext translator' do
    stub(view).truncate { mock('body').w base_heading_level: 2 }
    do_render
  end
end
