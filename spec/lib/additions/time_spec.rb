require 'spec_helper'
require 'additions/time'

describe Time, '"distance in words" addition' do
  it 'should return "future" for times in the future' do
    time = Time.now + 100
    expect(time.distance_in_words).to match(/future/)
  end

  it 'should return "now" when times are the same' do
    time = Time.now
    expect(time.distance_in_words).to match(/now/)
  end

  it 'should return human-friendly strings for times in the past' do
    # these examples are fairly brittle (closely tied to implementation)
    # keep them all in one place to localize the nastiness
    time = Time.now
    expect((time - 30).distance_in_words).to        match(/few seconds ago/)
    expect((time - 90).distance_in_words).to        match(/a minute ago/)
    expect((time - 150).distance_in_words).to       match(/couple of minutes ago/)
    expect((time - 240).distance_in_words).to       match(/few minutes ago/)
    expect((time - 600).distance_in_words).to       match(/10 minutes ago/)
    expect((time - 4_000).distance_in_words).to     match(/an hour ago/)
    expect((time - 8_000).distance_in_words).to     match(/2 hours ago/)
    expect((time - 90_000).distance_in_words).to    match(/yesterday/)
    expect((time - 200_000).distance_in_words).to   match(/2 days ago/)
    expect((time - 864_000).distance_in_words).to   match(/a week ago/)
    expect((time - 2_500_000).distance_in_words).to match(/4 weeks ago/)
  end

  it 'should return non-relative strings for times in the distant past' do
    time = Time.local(2007, 6, 20)
    expect(time.distance_in_words).to match(/20 June 2007/)
  end
end
