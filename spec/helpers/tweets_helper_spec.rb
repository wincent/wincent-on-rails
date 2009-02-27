require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TweetsHelper, '"atom_title" method' do
  it 'should strip HTML tags' do
    tweet = new_tweet :body => "foo ''bar''"
    helper.atom_title(tweet).should =~ /foo bar/
  end

  it 'should compress whitespace' do
    tweet = new_tweet :body => "foo    bar   \n   baz"
    helper.atom_title(tweet).should =~ /foo bar baz/
  end

  it 'should remove leading whitespace' do
    tweet = new_tweet :body => "  foo\n  bar"
    helper.atom_title(tweet).should =~ /\Afoo bar/
  end

  it 'should remove trailing whitespace' do
    tweet = new_tweet :body => "foo  \nbar  "
    helper.atom_title(tweet).should =~ /foo bar\z/
  end

  it 'should truncate long text to 80 characters' do
    tweet = new_tweet :body => 'x' * 100
    helper.atom_title(tweet).length.should == 80
  end
end

describe TweetsHelper, '"character_count" method' do
  # character_count calls pluralizing_count, defined in ApplicationHelper
  helper.extend ApplicationHelper

  it 'should pluralize 0-character tweets' do
    tweet = new_tweet :body => ''
    helper.character_count(tweet).should == '0 characters'
  end

  it 'should pluralize 1-character tweets' do
    tweet = new_tweet :body => 'x'
    helper.character_count(tweet).should == '1 character'
  end

  it 'should pluralize multi-character tweets' do
    tweet = new_tweet :body => 'foo bar'
    helper.character_count(tweet).should == '7 characters'
  end
end
