require 'spec_helper'

describe 'searches/_topic' do
  before do
    @topic          = Topic.make!
    @result_number  = 47
  end

  def do_render
    render 'searches/topic', :model => @topic, :result_number => @result_number
  end

  it 'shows the result number' do
    do_render
    rendered.should contain(@result_number.to_s)
  end

  it 'uses the topic title as link text' do
    do_render
    rendered.should have_selector('a', :content => @topic.title)
  end

  # was a bug
  it 'escapes HTML special characters in the topic summary' do
    @topic = Topic.make! :title => '<em>foo</em>'
    do_render
    rendered.should match('&lt;em&gt;foo&lt;/em&gt;')
    rendered.should_not have_selector('em', :content => 'foo')
  end

  it 'links to the topic' do
    do_render
    rendered.should have_selector('a', :href => topic_path(@topic))
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
    mock(view).truncate @topic.body, :length => 240
    do_render
  end

  it 'passes the truncated topic body through the wikitext translator' do
    stub(view).truncate { mock('body').w :base_heading_level => 2 }
    do_render
  end
end
