module CommentsHelper
  def button_to_moderate_comment_as_ham comment
    button_to_moderate_model_as_ham comment, comment_path(comment)
  end

  def comment_class comment
    if comment.user && comment.user.superuser?
      'admin'
    else
      cycle('even', 'odd')
    end + (comment.public? ? '' : ' private')
  end
end
