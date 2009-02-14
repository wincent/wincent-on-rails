class IssueMailer < ActionMailer::Base
  def new_issue_alert issue
    url_options = { :host => APP_CONFIG['host'] }
    if APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443
      url_options[:port] = APP_CONFIG['port']
    end
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

  def receive msg
    # process incoming mail!
    raise 'not yet implemented'
  end
end
