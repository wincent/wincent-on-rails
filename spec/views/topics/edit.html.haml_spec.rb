require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/topics/edit' do
  include TopicsHelper

  before do
    assigns[:forum] = @forum = create_forum
    assigns[:topic] = @topic = create_topic(:forum => @forum)
  end

  def do_render
    render '/topics/edit'
  end

  it 'should have a ham button if the topic is awaiting moderation' do
    assigns[:topic] = @topic = create_topic(:awaiting_moderation => true,
      :forum => @forum)
    template.should_receive(:button_to_moderate_topic_as_ham).with(@topic)
    do_render
  end

  it 'should not have a ham button if the issue is not awaiting moderation' do
    assigns[:topic] = @topic = create_topic(:awaiting_moderation => false,
      :forum => @forum)
    template.should_not_receive(:button_to_moderate_topic_as_ham)
    do_render
  end
end
