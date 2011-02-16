module CommentsHelper
  def button_to_moderate_comment_as_ham comment
    button_to_moderate_model_as_ham comment, comment_path(comment)
  end
end
