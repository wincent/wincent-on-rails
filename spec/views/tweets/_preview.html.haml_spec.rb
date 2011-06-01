require 'spec_helper'

describe 'tweets/_preview.html.haml' do
  def do_render
    assigns[:tweet] = @tweet
    render :partial => '/tweets/preview.html.haml'
  end

  before do
    @tweet = Tweet.make :body => 'hello'
  end

  it 'should display the rendered length' do
    do_render
    rendered.should =~ /\(5 characters\)/
  end

  it 'should correctly pluralize when rendered length is 0' do
    @tweet = Tweet.make :body => ''
    do_render
    rendered.should =~ /\(0 characters\)/
  end

  it 'should correctly pluralize when rendered length is 1' do
    @tweet = Tweet.make :body => 'a'
    do_render
    rendered.should =~ /\(1 character\)/
  end

  it 'should display overlength count using CSS span' do
    long = 'x' * 250
    @tweet = Tweet.make :body => long
    do_render
    rendered.should have_css('span.overlength', :content => '(250 characters)')
  end

  it 'should not use CSS span for short messages' do
    do_render
    rendered.should_not have_css('span.overlength')
  end

  it 'should show the tweet body' do
    do_render
    rendered.should =~ /hello/
  end

  it 'should render wikitext markup as HTML' do
    @tweet = Tweet.make :body => "'''foo'''"
    do_render
    rendered.should have_css('strong', :content => 'foo')
  end

  it 'should start with a "base heading level" of 3' do
    @tweet = Tweet.make :body => "= foo ="
    do_render
    rendered.should have_css('h4', :content => 'foo')
  end
end
