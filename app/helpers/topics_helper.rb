module TopicsHelper
  def button_to_destroy_topic topic
    haml_tag :form, { :id => "topic_#{topic.id}_destroy_form", :style => 'display:inline;' } do
      button = submit_to_remote 'button', 'destroy',
        :url      => forum_topic_path(topic.forum, topic),
        :method   => :delete,
        :failure  => "alert('Failed to delete')",
        :confirm  => 'Really delete?'
      concat button
    end
  end

  def button_to_moderate_topic_as_spam topic
    haml_tag :form, { :id => "topic_#{topic.id}_spam_form", :style => 'display:inline;' } do
      button = submit_to_remote 'button', 'spam',
        :url => forum_topic_path(topic.forum, topic),
        :method => :put,
        :failure => "alert('Failed to mark as spam')",
        :confirm => 'Really mark as spam?'
      concat button
    end
  end

  def button_to_moderate_topic_as_ham topic
    haml_tag :form, { :id => "topic_#{topic.id}_ham_form", :style => 'display:inline;' } do
      button = submit_to_remote 'button', 'ham',
        :url => forum_topic_path(topic.forum, topic),
        :method => :put,
        :failure => "alert('Failed to mark as ham')"
      concat button
    end
  end
end # module TopicsHelper
