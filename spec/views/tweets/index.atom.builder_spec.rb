require 'spec_helper'

describe 'tweets/index.atom.builder' do
  let(:doc) { Nokogiri::XML(rendered) }

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
    doc.at_xpath('/atom:feed/atom:updated', ATOM_XMLNS).content.
      should == RAILS_EPOCH.xmlschema
  end

  it 'uses the first tweet for the update date if available' do
    render
    doc.at_xpath('/atom:feed/atom:updated', ATOM_XMLNS).content.
      should == @tweets[0].updated_at.xmlschema
  end

  it 'uses the administrator as the feed author' do
    render
    author = doc.at_xpath('/atom:feed/atom:author', ATOM_XMLNS)
    author.at_xpath('atom:name', ATOM_XMLNS).content.
      should == APP_CONFIG['admin_name']
    author.at_xpath('atom:email', ATOM_XMLNS).content.
      should == APP_CONFIG['admin_email']
  end

  it 'uses the "tweet_title" helper to produce the entry titles' do
    mock(view).tweet_title(@tweets[0]) { 'atom title 0' }
    mock(view).tweet_title(@tweets[1]) { 'atom title 1' }
    render
    doc.xpath('/atom:feed/atom:entry', ATOM_XMLNS).map do |entry|
      entry.at_xpath('atom:title', ATOM_XMLNS).content
    end.should == ['atom title 0', 'atom title 1']
  end

  it 'includes the tweet text as HTML' do
    render
    doc.xpath('/atom:feed/atom:entry', ATOM_XMLNS).map do |entry|
      entry.at_xpath('atom:content', ATOM_XMLNS).content
    end.should == ["<p><em>foo</em></p>\n", "<p><strong>bar</strong></p>\n"]
  end
end
