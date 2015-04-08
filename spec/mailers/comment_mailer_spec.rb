require 'spec_helper'

describe CommentMailer do
  describe 'new comment alert' do
    let (:comment)  { @comment = Comment.make! }
    let (:mail)     { CommentMailer.new_comment_alert comment }

    it 'has content-type "text/plain"' do
      expect(mail.content_type).to match(%r{text/plain}) # ignore charset
    end

    it 'sets the subject line' do
      expect(mail.subject).to match(/new comment/)
    end

    it 'is addressed to the site administrator' do
      expect(mail.to.length).to eq(1)
      expect(mail.to.first).to eq(APP_CONFIG['admin_email'])
    end

    it 'is from the support address' do
      expect(mail.from.length).to eq(1)
      expect(mail.from.first).to eq(APP_CONFIG['support_email'])
    end

    context 'unmoderated comment' do
      let (:comment) { Comment.make! :awaiting_moderation => false }

      it 'shows "not awaiting moderation"' do
        expect(mail.body).to match(/not awaiting moderation/)
      end
    end

    context 'moderated comment' do
      let(:comment) { Comment.make! :awaiting_moderation => true }

      it 'shows "awaiting moderation"' do
        expect(mail.body).to match(/awaiting moderation/)
        expect(mail.body).not_to match(/not awaiting moderation/)
      end
    end

    it 'shows the comment body in the body' do
      expect(mail.body).to match(/#{comment.body}/)
    end

    context 'comment with HTML special characters' do
      let (:comment) { Comment.make! :body => 'I believe 3 is > 2.' }

      it 'does not HTML-escape the body, as the email is text/plain' do
        expect(mail.body).to match(/3 is > 2/)
      end
    end

    it 'includes a link to the administator dashboard' do
      expect(mail.body).to match(/#{admin_dashboard_url}/)
    end

    it 'includes a link to the comment edit form' do
      expect(mail.body).to match(/#{edit_comment_url(comment)}/)
    end

    it 'includes "support@wincent.com" in the Message-ID header' do
      expect(mail.header['message-id'].to_s).to match(%r{\A<.+support@wincent.com>\z})
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      expect(mail.header['return-path'].to_s).
        to match(/#{Regexp.escape APP_CONFIG['support_email']}/)
    end

    it 'creates a corresponding Message object' do
      message = Message.find_by_message_id_header(mail.header['message-id'].to_s)
      expect(message.related).to eq(comment)
    end
  end
end
