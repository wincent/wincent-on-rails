require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'tweets/show.html.haml' do
  def do_render
    assign :tweet, @tweet
    assign :comments, @tweet.comments.published
    render
  end

  before do
    @tweet = Tweet.make! :body => "''hello''"
    view.extend TweetsHelper
    view.extend ApplicationHelper
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs(/Twitter/, /Tweet #/)
    do_render
  end

  it 'should show the tweet body as HTML' do
    do_render
    rendered.should match(%r{<em>hello</em>})
  end

  it 'should show the time information for the tweet' do
    mock(view).timeinfo(@tweet)
    do_render
  end

  it 'should have an link to the tweets index' do
    pending 'need replacement for have_tag matcher' # was a wrapper for assert_select, no longer in RSpec
    do_render
    rendered.should have_tag('.links') do
      with_tag 'a[href=?]', tweets_path
    end
  end

  it 'should show the tweet number' do
    do_render
    rendered.should contain(/Tweet ##{@tweet.id}/)
  end
end
