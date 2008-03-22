module ForumsHelper

  # this helper expects a couple of custom fields to be present added by the Forums#show action:
  # last_active_user_id, and last_active_user_display_name
  def topic_user_link topic
    # we're creating a temporary User object here, but it beats hitting the database
    link_to_user(topic.last_active_user_id.nil? ? nil : User.new(:display_name => topic.last_active_user_display_name))
  end

end
