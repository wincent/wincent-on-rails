module TopicsHelper
  def timeinfo_for_topic topic
    "posted #{topic.created_at.distance_in_words}"
  end
end # module TopicsHelper
