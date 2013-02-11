require 'spec_helper'

describe 'search/_tweet' do
  before do
    @tweet          = Tweet.make!
    @result_number  = 47
  end

  def do_render
    render 'search/tweet', model: @tweet, result_number: @result_number
  end

  it 'shows the result number' do
    do_render
    rendered.should have_content(@result_number.to_s)
  end

  it 'links to the tweet' do
    do_render
    rendered.should have_link("Tweet \##{@tweet.id}", href: tweet_path(@tweet))
  end

  it 'shows the timeinfo for the tweet' do
    mock(view).timeinfo(@tweet)
    do_render
  end

  it 'gets the tweet body' do
    mock(@tweet).body
    do_render
  end

  it 'truncates the tweet body to 240 characters' do
    mock(view).truncate(@tweet.body, length: 240)
    do_render
  end

  it 'passes the truncated tweet body through the wikitext translator' do
    stub(view).truncate { mock('body').w base_heading_level: 2 }
    do_render
  end
end
