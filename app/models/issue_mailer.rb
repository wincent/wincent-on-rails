class IssueMailer < ActionMailer::Base
  def new_issue_alert issue
    url_options = { :host => APP_CONFIG['host'] }
    url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80
    subject     "new issue alert from #{APP_CONFIG['host']}"
    body({
      :issue          => issue,
      :issue_url      => edit_issue_url(issue, url_options), # Issues#edit doesn't work yet but it will
      :moderation_url => admin_dashboard_url(url_options)
      })
    recipients  APP_CONFIG['admin_email']
    from        APP_CONFIG['admin_email']
    sent_on     Time.now
    headers     {}
  end
end
