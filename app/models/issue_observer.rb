class IssueObserver < ActiveRecord::Observer
  def after_create issue
    send_new_issue_alert issue unless issue.user && issue.user.superuser?
  end

private

  def send_new_issue_alert issue
    IssueMailer.new_issue_alert(issue).deliver
  rescue Exception => e
    Rails.logger.error \
      "IssueObserver#send_new_issue_alert for issue #{issue.inspect} " \
      "failed due to exception #{e.class}: #{e.message}"
  end
end # class IssueObserver
