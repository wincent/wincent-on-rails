require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ForumsHelper do
  describe '#timeinfo_for_forum' do
    context 'an empty forum' do
      let (:forum) do
        Forum.make!

        # the last_active_at column isn't a real attribute
        # but is set up inside the Forum.find_all method
        Forum.find_all.first
      end

      it 'returns "no activity"' do
        timeinfo_for_forum(forum).should == 'no activity'
      end
    end

    context 'a forum with a new topic' do
      let(:forum) do
        Topic.make!

        # the last_active_at column isn't a real attribute
        # but is set up inside the Forum.find_all method
        Forum.find_all.first
      end

      it 'returns a distance in words' do
        # could get either of these on a slow run, so accept either
        timeinfo_for_forum(forum).should =~ /\A(now|a few seconds ago)\z/
      end
    end
  end
end
