class SupportMailer < ActionMailer::Base
  @@sanitizer = nil
  def self.sanitize text
    @@sanitizer ||= HTML::FullSanitizer.new
    text = @@sanitizer.sanitize text  # strip HTML tags
    text.gsub! /<!DOCTYPE[^>]*>/, ''  # strip DOCTYPE
    text.gsub! /^[ \t]+$/, ''         # compress lines containing only whitespace
    text.gsub! /^[ \t]+/, ''          # strip leading whitespace
    text
  end

  # returns an array of plain-text parts as strings
  def self.plain_text_parts_from_email email
    if !email.multipart? and email.content_type == 'text/plain'
      return [email.body.to_s]
    end
    parts = email.parts.collect do |part|
      if part.multipart?
        plain_text_parts_from_email part
      elsif part.content_type == 'text/plain'
        part.body.to_s
      else
        nil
      end
    end
    parts.flatten.compact
  end

  def self.plain_text_from_email email
    parts = plain_text_parts_from_email email
    if parts.empty?
      sanitize email.body.to_s
    else
      parts.join
    end
  end

  def receive email
    message = Message.new :message_id_header => email.message_id,
                          :subject_header => email.subject,
                          :in_reply_to_header => email.in_reply_to,
                          :body => SupportMailer.plain_text_from_email(email)
    message.to_header   = email.to.first if email.to
    message.from_header = email.from.first if email.from

    # basic case: open a new ticket
    new_issue_from_message message

    # may also consult email.references looking for Message-ID
    # and email.subject eg "Ticket #12" etc
  rescue Exception => e
    message.save
    raise e
  ensure
    message.save
  end

private

  def new_issue_from_message message
    issue = Issue.new :summary => message.subject_header
    issue.description = message.body ? message.body : message.subject_header
    user = message.from_header ? User.find_by_email(message.from_header) : nil

    # TODO: UI for reassigned tickets to other users (if spammers use fake addresses)
    # TODO: auto-create accounts for users who don't have accounts yet
    issue.user = user
    issue.save
    message.related = issue # saved by caller
  end
end
