class IssueMailer < ActionMailer::Base
  def new_issue_alert issue
    subject(subject_header = "new issue alert from #{APP_CONFIG['host']}")
    body({
      :issue          => issue,
      :issue_url      => edit_issue_url(issue),
      :moderation_url => admin_dashboard_url
      })
    recipients(to_header = APP_CONFIG['admin_email'])
    from(from_header = APP_CONFIG['admin_email'])
    sent_on Time.now

    # unfortunately domain will be 'wincent.com.tmail'
    headers 'Message-ID' => (message_id_header = TMail.new_message_id 'wincent.com')
    Message.create  :related => issue,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false
  end

  def receive msg
    # process incoming mail!
    raise 'not yet implemented'
  end
end
