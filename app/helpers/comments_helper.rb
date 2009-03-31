module CommentsHelper
  def button_to_destroy_comment comment
    button_to_destroy_model comment, comment_url(comment)
  end

  def button_to_moderate_comment_as_ham comment
    button_to_moderate_model_as_ham comment, comment_url(comment)
  end
end
