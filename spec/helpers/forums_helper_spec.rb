require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ForumsHelper do
  describe '#link_to_user_for_topic' do
    include ApplicationHelper # for link_to_user method

    describe 'regressions' do
      describe 'https://wincent.com/issues/1670' do
        it "doesn't throw a routing error due to a nil value" do
          # this may be code smell, but this method depends on the
          # last_active_user_id attribute, which is not a real attribute but a
          # pseudo-attribute added by the Topic.find_topics_for_forum method.
          topic = Topic.make! :user => User.make!
          topics = Topic.find_topics_for_forum topic.forum
          link_to_user_for_topic topics.first
        end
      end
    end
  end

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
        #
        # BUG: that's actually a code smell, and should be updated
        # in a callback
        Forum.find_all.first
      end

      it 'returns a distance in words' do
        # could get either of these on a slow run, so accept either
        timeinfo_for_forum(forum).should =~ /\A(now|a few seconds ago)\z/
      end
    end
  end
end
