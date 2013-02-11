require 'spec_helper'

describe 'tweets/_preview.html.haml' do
  before do
    @tweet = Tweet.make body: 'hello'
  end

  it 'should display the rendered length' do
    render
    rendered.should =~ /\(5 characters\)/
  end

  it 'should correctly pluralize when rendered length is 0' do
    @tweet = Tweet.make body: ''
    render
    rendered.should =~ /\(0 characters\)/
  end

  it 'should correctly pluralize when rendered length is 1' do
    @tweet = Tweet.make body: 'a'
    render
    rendered.should =~ /\(1 character\)/
  end

  it 'should display overlength count using CSS span' do
    long = 'x' * 250
    @tweet = Tweet.make body: long
    render
    rendered.should have_css('span.overlength', text: '(250 characters)')
  end

  it 'should not use CSS span for short messages' do
    render
    rendered.should_not have_css('span.overlength')
  end

  it 'should show the tweet body' do
    render
    rendered.should =~ /hello/
  end

  it 'should render wikitext markup as HTML' do
    @tweet = Tweet.make body: "'''foo'''"
    render
    rendered.should have_css('strong', text: 'foo')
  end

  it 'should start with a "base heading level" of 3' do
    @tweet = Tweet.make body: "= foo ="
    render
    rendered.should have_css('h4', text: 'foo')
  end
end
