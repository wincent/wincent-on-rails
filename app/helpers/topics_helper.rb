module TopicsHelper
  def button_to_destroy_topic topic
    button_to_destroy_model topic
  end

  def button_to_moderate_topic_as_ham topic
    button_to_moderate_model_as_ham topic, forum_topic_path(topic.forum, topic)
  end
end # module TopicsHelper
