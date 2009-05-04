require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
