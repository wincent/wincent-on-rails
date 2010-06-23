require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/tweets/_preview.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:tweet] = @tweet
    render :partial => '/tweets/preview.html.haml'
  end

  before do
    @tweet = new_tweet :body => 'hello'
  end

  it 'should display the rendered length' do
    do_render
    response.body.should =~ /\(5 characters\)/
  end

  it 'should correctly pluralize when rendered length is 0' do
    @tweet = new_tweet :body => ''
    do_render
    response.body.should =~ /\(0 characters\)/
  end

  it 'should correctly pluralize when rendered length is 1' do
    @tweet = new_tweet :body => 'a'
    do_render
    response.body.should =~ /\(1 character\)/
  end

  it 'should display overlength count using CSS span' do
    long = 'x' * 250
    @tweet = new_tweet :body => long
    do_render
    response.should have_tag('span.overlength', /\(250 characters\)/)
  end

  it 'should not use CSS span for short messages' do
    do_render
    response.should_not have_tag('span.overlength')
  end

  it 'should show the tweet body' do
    do_render
    response.body.should =~ /hello/
  end

  it 'should render wikitext markup as HTML' do
    @tweet = new_tweet :body => "'''foo'''"
    do_render
    response.should have_tag('strong', 'foo')
  end

  it 'should start with a "base heading level" of 3' do
    @tweet = new_tweet :body => "= foo ="
    do_render
    response.should have_tag('h4', 'foo')
  end
end
