module TopicsHelper
  def timeinfo_for_topic topic
    topic.created_at.distance_in_words
  end
end # module TopicsHelper
