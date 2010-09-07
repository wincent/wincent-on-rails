require 'spec_helper'
require 'additions/time'

describe Time, '"distance in words" addition' do
  it 'should return "future" for times in the future' do
    time = Time.now + 100
    time.distance_in_words.should =~ /future/
  end

  it 'should return "now" when times are the same' do
    time = Time.now
    time.distance_in_words.should =~ /now/
  end

  it 'should return human-friendly strings for times in the past' do
    # these examples are fairly brittle (closely tied to implementation)
    # keep them all in one place to localize the nastiness
    time = Time.now
    (time - 30).distance_in_words.should        =~ /few seconds ago/
    (time - 90).distance_in_words.should        =~ /a minute ago/
    (time - 150).distance_in_words.should       =~ /couple of minutes ago/
    (time - 240).distance_in_words.should       =~ /few minutes ago/
    (time - 600).distance_in_words.should       =~ /10 minutes ago/
    (time - 4_000).distance_in_words.should     =~ /an hour ago/
    (time - 8_000).distance_in_words.should     =~ /2 hours ago/
    (time - 90_000).distance_in_words.should    =~ /yesterday/
    (time - 200_000).distance_in_words.should   =~ /2 days ago/
    (time - 864_000).distance_in_words.should   =~ /a week ago/
    (time - 2_500_000).distance_in_words.should =~ /4 weeks ago/
  end

  it 'should return non-relative strings for times in the distant past' do
    time = Time.local(2007, 6, 20)
    time.distance_in_words.should =~ /20 June 2007/
  end
end
