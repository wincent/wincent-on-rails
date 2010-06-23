require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/tweets/index.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:tweets] = @tweets
    render '/tweets/_tweets.html.haml'
  end

  before do
    @tweets = [
      create_tweet(:body => "''foo''"),
      create_tweet(:body => "'''bar'''")
    ]
  end

  it 'should display a div for each tweet' do
    do_render
    response.should have_tag('div.tweet', 2)
  end

  it 'should display the HTML body of each tweet' do
    do_render
    response.body.should =~ %r{<em>foo</em>}
    response.body.should =~ %r{<strong>bar</strong>}
  end

  it 'should show the time information for each tweet' do
    template.should_receive(:timeinfo).with(@tweets[0])
    template.should_receive(:timeinfo).with(@tweets[1])
    do_render
  end

  it 'should show a permalink for each tweet' do
    do_render
    response.should have_tag('a[href=?]', tweet_path(@tweets[0]), 'permalink')
    response.should have_tag('a[href=?]', tweet_path(@tweets[1]), 'permalink')
  end
end
