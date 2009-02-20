class IssueMailer < ActionMailer::Base
  def new_issue_alert issue
    subject     "new issue alert from #{APP_CONFIG['host']}"
    body({
      :issue          => issue,
      :issue_url      => edit_issue_url(issue),
      :moderation_url => admin_dashboard_url
      })
    recipients  APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end

  def receive msg
    # process incoming mail!
    raise 'not yet implemented'
  end
end
