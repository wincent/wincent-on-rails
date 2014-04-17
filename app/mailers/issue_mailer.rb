class IssueMailer < ActionMailer::Base
  default return_path: APP_CONFIG['support_email']

  def new_issue_alert issue
    subject_prefix = '[ALERT] ' unless issue.awaiting_moderation?
    message = Message.create \
      related:        issue,
      to_header:      APP_CONFIG['admin_email'],
      from_header:    APP_CONFIG['support_email'],
      subject_header: "#{subject_prefix}new issue on #{APP_CONFIG['host']}",
      incoming:       false

    @issue          = issue
    @edit_issue_url = edit_issue_url(issue)
    @issue_url      = issue_url(issue)
    @moderation_url = admin_dashboard_url

    mail  subject:    message.subject_header,
          to:         message.to_header,
          from:       message.from_header,
          date:       Time.now,
          message_id: message.message_id_header
  end
end
