require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'hpricot'

describe 'tweets/index.atom.builder' do
  before do
    @tweets = [
      Tweet.make!(:body => "''foo''"),
      Tweet.make!(:body => "'''bar'''")
    ]
    assigns[:tweets] = @tweets
  end

  # was a bug
  it 'handles no tweets' do
    @tweets = []
    lambda { render }.should_not raise_error
  end

  it 'handles some tweets' do
    lambda { render }.should_not raise_error
  end

  it 'uses the custom Atom feed helper' do
    mock(view).custom_atom_feed
    render
  end

  it 'uses the "Rails Epoch" as an update date if there are no tweets' do
    @tweets = []
    render
    doc = Hpricot.XML(rendered)
    doc.at('feed').at('updated').innerHTML.should == RAILS_EPOCH.xmlschema
  end

  it 'uses the first tweet for the update date if available' do
    render
    doc = Hpricot.XML(rendered)
    doc.at('feed').at('updated').innerHTML.should == @tweets[0].updated_at.xmlschema
  end

  it 'uses the administrator as the feed author' do
    render
    doc = Hpricot.XML(rendered)
    author = doc.at('feed').at('author')
    author.at('name').innerHTML.should == APP_CONFIG['admin_name']
    author.at('email').innerHTML.should == APP_CONFIG['admin_email']
  end

  it 'uses the "tweet_title" helper to produce the entry titles' do
    mock(view).tweet_title(@tweets[0]) { 'atom title 0' }
    mock(view).tweet_title(@tweets[1]) { 'atom title 1' }
    render
    doc = Hpricot.XML(rendered)
    entry = doc.at('feed').at('entry')
    entry.at('title').innerHTML.should == 'atom title 0'
    entry = entry.next_sibling
    entry.at('title').innerHTML.should == 'atom title 1'
  end

  it 'includes the tweet text as escaped HTML' do
    render
    doc = Hpricot.XML(rendered)
    entry = doc.at('feed').at('entry')
    entry.at('content').innerHTML.should == "&lt;p&gt;&lt;em&gt;foo&lt;/em&gt;&lt;/p&gt;\n"
    entry = entry.next_sibling
    entry.at('content').innerHTML.should == "&lt;p&gt;&lt;strong&gt;bar&lt;/strong&gt;&lt;/p&gt;\n"
  end
end
