module TopicsHelper
  def timeinfo_for_topic topic
    "posted #{topic.created_at.distance_in_words}"
  end

  def timeinfo_for_topic_comment comment
    created = comment.created_at
    updated = comment.updated_at
    if created == updated
      "posted #{created.distance_in_words}"
    else
      "posted #{created.distance_in_words}, edited #{updated.distance_in_words}"
    end
  end
end # module TopicsHelper
