module CommentsHelper
  def button_to_destroy_comment comment
    button_to_destroy_model comment, comment_path(comment)
  end

  def button_to_moderate_comment_as_spam comment
    button_to_moderate_model_as_spam comment, comment_path(comment)
  end

  def button_to_moderate_comment_as_ham comment
    button_to_moderate_model_as_ham comment, comment_path(comment)
  end
end
