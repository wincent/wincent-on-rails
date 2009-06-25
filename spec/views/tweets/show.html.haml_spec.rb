require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/tweets/show.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:tweet]     = @tweet
    assigns[:comments]  = @tweet.comments.published
    render '/tweets/show.html.haml'
  end

  before do
    @tweet = create_tweet :body => "''hello''"
  end

  it 'should show the tweet body as HTML' do
    do_render
    response.body.should =~ %r{<em>hello</em>}
  end

  it 'should show the time information for the tweet' do
    template.should_receive(:timeinfo).with(@tweet)
    do_render
  end

  it 'should have an link to the tweets index' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', tweets_path
    end
  end

  it 'should show the tweet number' do
    do_render
    response.body.should =~ /Tweet ##{@tweet.id}/
  end
end
