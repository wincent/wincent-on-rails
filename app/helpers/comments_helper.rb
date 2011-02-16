module CommentsHelper
  def button_to_moderate_comment_as_ham comment
    button_to_moderate_model_as_ham comment, comment_path(comment)
  end

  def link_to_parent parent
    case parent
    when Article
      link_to parent.title, article_path(parent)
    when Issue
      link_to "issue \##{parent.id}", issue_path(parent)
    when Post
      link_to parent.title, post_path(parent)
    when Snippet
      link_to "snippet \##{parent.id}", snippet_path(parent)
    when Topic
      link_to parent.title, forum_topic_path(parent.forum, parent)
    when Tweet
      link_to "tweet \##{parent.id}", tweet_path(parent)
    end
  end
end
