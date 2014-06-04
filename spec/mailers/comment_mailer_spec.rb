require 'spec_helper'

describe CommentMailer do
  describe 'new comment alert' do
    let (:comment)  { @comment = Comment.make! }
    let (:mail)     { CommentMailer.new_comment_alert comment }

    it 'has content-type "text/plain"' do
      mail.content_type.should =~ %r{text/plain} # ignore charset
    end

    it 'sets the subject line' do
      mail.subject.should =~ /new comment/
    end

    it 'is addressed to the site administrator' do
      mail.to.length.should == 1
      mail.to.first.should == APP_CONFIG['admin_email']
    end

    it 'is from the support address' do
      mail.from.length.should == 1
      mail.from.first.should == APP_CONFIG['support_email']
    end

    context 'unmoderated comment' do
      let (:comment) { Comment.make! :awaiting_moderation => false }

      it 'shows "not awaiting moderation"' do
        mail.body.should match(/not awaiting moderation/)
      end
    end

    context 'moderated comment' do
      let(:comment) { Comment.make! :awaiting_moderation => true }

      it 'shows "awaiting moderation"' do
        mail.body.should match(/awaiting moderation/)
        mail.body.should_not match(/not awaiting moderation/)
      end
    end

    it 'shows the comment body in the body' do
      mail.body.should match(/#{comment.body}/)
    end

    context 'comment with HTML special characters' do
      let (:comment) { Comment.make! :body => 'I believe 3 is > 2.' }

      it 'does not HTML-escape the body, as the email is text/plain' do
        mail.body.should match(/3 is > 2/)
      end
    end

    it 'includes a link to the administator dashboard' do
      mail.body.should match(/#{admin_dashboard_url}/)
    end

    it 'includes a link to the comment edit form' do
      mail.body.should match(/#{edit_comment_url(comment)}/)
    end

    it 'includes "support@wincent.com" in the Message-ID header' do
      mail.header['message-id'].to_s.should =~ %r{\A<.+support@wincent.com>\z}
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      mail.header['return-path'].to_s.
        should =~ /#{Regexp.escape APP_CONFIG['support_email']}/
    end

    it 'creates a corresponding Message object' do
      message = Message.find_by_message_id_header(mail.header['message-id'].to_s)
      message.related.should == comment
    end
  end
end
