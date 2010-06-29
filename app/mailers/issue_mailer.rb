class IssueMailer < ActionMailer::Base
  def new_issue_alert issue
    subject(subject_header = "new issue alert from #{APP_CONFIG['host']}")
    @issue          = issue
    @issue_url      = edit_issue_url(issue)
    @moderation_url = admin_dashboard_url
    recipients(to_header = APP_CONFIG['admin_email'])
    from(from_header = APP_CONFIG['support_email'])
    sent_on Time.now
    headers 'Message-ID' => (message_id_header = SupportMailer.new_message_id),
            'return-path' => from_header
    Message.create  :related => issue,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false
  end
end
