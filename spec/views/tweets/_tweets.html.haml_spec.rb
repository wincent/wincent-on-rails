require 'spec_helper'

describe 'tweets/_tweets.html.haml' do
  before do
    @tweets = [
      Tweet.make!(:body => "''foo''"),
      Tweet.make!(:body => "'''bar'''")
    ]
    assigns[:tweets] = @tweets
  end

  it 'should display a div for each tweet' do
    render
    rendered.should have_css('div.tweet', :count => 2)
  end

  it 'should display the HTML body of each tweet' do
    render
    rendered.should =~ %r{<em>foo</em>}
    rendered.should =~ %r{<strong>bar</strong>}
  end

  it 'should show the time information for each tweet' do
    mock(view).timeinfo(@tweets[0])
    mock(view).timeinfo(@tweets[1])
    render
  end

  it 'should show a permalink for each tweet' do
    render
    rendered.should have_css("a[href='/twitter/#{@tweets[0].id}']", :content => 'permalink')
    rendered.should have_css("a[href='/twitter/#{@tweets[1].id}']", :content => 'permalink')
  end
end
