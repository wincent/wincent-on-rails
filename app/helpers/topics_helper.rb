module TopicsHelper
  def button_to_moderate_topic_as_ham topic
    button_to_moderate_model_as_ham topic, forum_topic_path(topic.forum, topic)
  end
end # module TopicsHelper
