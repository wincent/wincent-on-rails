require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_tweet' do
  before do
    @tweet          = create_tweet
    @result_number  = 47
  end

  def do_render
    render :partial => '/search/tweet', :locals => { :model => @tweet, :result_number => @result_number }
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the tweet number in the link text' do
    do_render
    response.should have_tag('a', "Tweet \##{@tweet.id}")
  end

  it 'should link to the tweet' do
    do_render
    response.should have_tag('a[href=?]', tweet_path(@tweet))
  end

  it 'should show the timeinfo for the tweet' do
    template.should_receive(:timeinfo).with(@tweet)
    do_render
  end

  it 'should get the tweet body' do
    @tweet.should_receive(:body).and_return('foo')
    do_render
  end

  it 'should truncate the tweet body to 240 characters' do
    template.should_receive(:truncate).with(@tweet.body, :length => 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated tweet body through the wikitext translator' do
    body = 'foo'
    body.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(body)
    do_render
  end
end
