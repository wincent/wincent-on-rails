class IssueMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def new_issue_alert issue
    message = Message.create \
      :related            => issue,
      :message_id_header  => SupportMailer.new_message_id,
      :to_header          => APP_CONFIG['admin_email'],
      :from_header        => APP_CONFIG['support_email'],
      :subject_header     => "new issue alert from #{APP_CONFIG['host']}",
      :incoming           => false

    headers['Message-Id'] = message.message_id_header

    @issue          = issue
    @issue_url      = edit_issue_url(issue)
    @moderation_url = admin_dashboard_url

    mail  :subject  => message.subject_header,
          :to       => message.to_header,
          :from     => message.from_header,
          :date     => Time.now
  end
end
