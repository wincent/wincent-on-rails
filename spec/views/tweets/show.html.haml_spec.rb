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

  it 'includes "ajax.js"' do
    mock(view).javascript_include_tag('ajax')
    do_render
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs(/Twitter/, /Tweet #/)
    do_render
  end

  it 'shows the tweet number' do
    do_render
    rendered.should contain("Tweet ##{@tweet.id}")
  end

  it 'shows the time information for the tweet' do
    mock(view).timeinfo(@tweet)
    do_render
  end

  it 'shows a by-line' do
    do_render
    rendered.should contain("by #{APP_CONFIG['admin_name']}")
  end

  it 'shows the tweet body as HTML' do
    do_render
    rendered.should have_selector('em', :content => 'hello')
  end

  it 'renders the "shared/tags" partial' do
    pending "can't mock this because do_render() will call render() first"
    mock(view).render('shared/tags', anything)
    do_render
  end

  it 'has a link to the tweets index' do
    do_render
    rendered.should have_selector('.links a', :href => tweets_path)
  end
end
