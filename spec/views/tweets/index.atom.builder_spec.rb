require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'hpricot'

describe '/tweets/index.atom.builder' do
  include TweetsHelper

  def do_render
    assigns[:tweets] = @tweets
    render '/tweets/index.atom.builder'
  end

  before do
    @tweets = [
      create_tweet(:body => "''foo''"),
      create_tweet(:body => "'''bar'''")
    ]
  end

  # was a bug
  it 'should handle no tweets' do
    @tweets = []
    lambda { do_render }.should_not raise_error
  end

  it 'should handle some tweets' do
    lambda { do_render }.should_not raise_error
  end

  it 'should use the custom Atom feed helper' do
    template.should_receive(:custom_atom_feed)
    do_render
  end

  it 'should use the "Rails Epoch" as an update date if there are no tweets' do
    @tweets = []
    do_render
    doc = Hpricot.XML(response.body)
    doc.at('feed').at('updated').innerHTML.should == RAILS_EPOCH.xmlschema
  end

  it 'should use the first tweet for the update date if available' do
    do_render
    doc = Hpricot.XML(response.body)
    doc.at('feed').at('updated').innerHTML.should == @tweets[0].updated_at.xmlschema
  end

  it 'should use the administrator as the feed author' do
    do_render
    doc = Hpricot.XML(response.body)
    author = doc.at('feed').at('author')
    author.at('name').innerHTML.should == 'Wincent Colaiuta'
    author.at('email').innerHTML.should == APP_CONFIG['admin_email']
  end

  it 'should use the "tweet_title" helper to produce the entry titles' do
    template.should_receive(:tweet_title).with(@tweets[0]).and_return('atom title 0')
    template.should_receive(:tweet_title).with(@tweets[1]).and_return('atom title 1')
    do_render
    doc = Hpricot.XML(response.body)
    entry = doc.at('feed').at('entry')
    entry.at('title').innerHTML.should == 'atom title 0'
    entry = entry.next_sibling
    entry.at('title').innerHTML.should == 'atom title 1'
  end

  it 'should include the tweet text as escaped HTML' do
    do_render
    doc = Hpricot.XML(response.body)
    entry = doc.at('feed').at('entry')
    entry.at('content').innerHTML.should == "&lt;p&gt;&lt;em&gt;foo&lt;/em&gt;&lt;/p&gt;\n"
    entry = entry.next_sibling
    entry.at('content').innerHTML.should == "&lt;p&gt;&lt;strong&gt;bar&lt;/strong&gt;&lt;/p&gt;\n"
  end
end
