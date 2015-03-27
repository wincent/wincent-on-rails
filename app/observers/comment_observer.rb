class CommentObserver < ActiveRecord::Observer
  def after_create comment
    send_new_comment_alert comment unless comment.user && comment.user.superuser?
  end

private

  def send_new_comment_alert comment
    CommentMailer.new_comment_alert(comment).deliver_now
  rescue Exception => e
    Rails.logger.error \
      "CommentObserver#send_new_comment_alert for comment #{comment.id} " \
      "failed due to exception #{e.class}: #{e.message}"
  end
end # class CommentObserver
