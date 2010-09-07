require 'spec_helper'

describe TweetsHelper, '"character_count" method' do
  # character_count calls pluralizing_count, defined in ApplicationHelper
  include ApplicationHelper

  it 'should pluralize 0-character tweets' do
    tweet = Tweet.make :body => ''
    character_count(tweet).should == '0 characters'
  end

  it 'should pluralize 1-character tweets' do
    tweet = Tweet.make :body => 'x'
    character_count(tweet).should == '1 character'
  end

  it 'should pluralize multi-character tweets' do
    tweet = Tweet.make :body => 'foo bar'
    character_count(tweet).should == '7 characters'
  end
end
