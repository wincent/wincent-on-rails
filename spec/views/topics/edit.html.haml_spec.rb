require 'spec_helper'

describe 'topics/edit' do
  before do
    @forum = Forum.make!
    @topic = Topic.make! :forum => @forum
  end

  it 'should have a ham button if the topic is awaiting moderation' do
    @topic = Topic.make! :awaiting_moderation => true, :forum => @forum
    mock(view).button_to_moderate_topic_as_ham(@topic)
    render
  end

  it 'should not have a ham button if the issue is not awaiting moderation' do
    @topic = Topic.make! :awaiting_moderation => false, :forum => @forum
    do_not_allow(view).button_to_moderate_topic_as_ham
    render
  end
end
