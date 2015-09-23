module ForumsHelper
  # this helper expects a couple of custom fields to be present added by the Forums#show action:
  # last_active_user_id, and last_active_user_display_name
  def link_to_user_for_topic topic
    # we're creating a temporary User object here, but it beats hitting the database
    link_to_user(topic.last_active_user_id.nil? ? nil : User.new(display_name: topic.last_active_user_display_name))
  end

  # again we rely on a custom field to be set up in the Forums#index action: last_topic_id
  def link_to_topic_for_forum forum
    return if forum.last_topic_id.nil?
    link_to 'view &raquo;'.html_safe,
      "#{forum_path forum}/topics/#{forum.last_topic_id}"
  end

  def timeinfo_for_forum forum
    forum.last_active_at ? forum.last_active_at.distance_in_words : 'no activity'
  end
end
