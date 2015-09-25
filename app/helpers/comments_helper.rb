module CommentsHelper
  # Return an appropriate class for commentish (eg. a comment instance), based
  # on whether it belongs to a superuser or is private.
  def comment_class(commentish)
    'comment'.tap do |css_class|
      css_class << ' admin' if commentish.user.try(:superuser?)
      css_class << ' private' unless commentish.public?
    end
  end
end
