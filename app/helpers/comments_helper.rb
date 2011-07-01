module CommentsHelper
  def button_to_moderate_comment_as_ham comment
    button_to_moderate_model_as_ham comment, polymorphic_path([comment.commentable, comment])
  end

  # Return an appropriate class for commentish (a comment or topic
  # instance), based on whether it is in an odd or even row, belongs
  # to a superuser, or is private.
  def comment_class commentish
    style = 'comment ' + cycle('even', 'odd')
    style += ' admin' if commentish.user.try(:superuser?)
    style += ' private' unless commentish.public?
    style
  end
end
