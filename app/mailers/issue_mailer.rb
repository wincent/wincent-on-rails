class IssueMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def new_issue_alert issue
    subject_header        = "new issue alert from #{APP_CONFIG['host']}"
    to_header             = APP_CONFIG['admin_email']
    from_header           = APP_CONFIG['support_email']
    headers['Message-Id'] = message_id_header = SupportMailer.new_message_id

    @issue          = issue
    @issue_url      = edit_issue_url(issue)
    @moderation_url = admin_dashboard_url

    Message.create  :related => issue,
                    :message_id_header => message_id_header,
                    :to_header => to_header,
                    :from_header => from_header,
                    :subject_header => subject_header,
                    :incoming => false

    mail  :subject  => subject_header,
          :to       => to_header,
          :from     => from_header,
          :date     => Time.now
  end
end
