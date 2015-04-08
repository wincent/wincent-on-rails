require 'spec_helper'

describe IssueMailer do
  describe 'new issue alert' do
    let (:issue)  { Issue.make! }
    let (:mail)   { IssueMailer.new_issue_alert issue }

    it 'has content-type "text/plain"' do
      expect(mail.content_type).to match(%r{text/plain}) # ignore charset
    end

    it 'sets the subject line' do
      expect(mail.subject).to match(/new issue/)
    end

    it 'is addressed to the site administrator' do
      expect(mail.to.length).to eq(1)
      expect(mail.to.first).to eq(APP_CONFIG['admin_email'])
    end

    it 'is from the support address' do
      expect(mail.from.length).to eq(1)
      expect(mail.from.first).to eq(APP_CONFIG['support_email'])
    end

    context 'moderated issue' do
      let (:issue) { Issue.make! :awaiting_moderation => true }

      it 'shows "awaiting moderation"' do
        expect(mail.body).to match(/awaiting moderation/)
        expect(mail.body).not_to match(/not awaiting moderation/)
      end
    end

    context 'unmoderated issue' do
      let (:issue) { Issue.make! :awaiting_moderation => false }

      it 'shows "not awaiting moderation"' do
        expect(mail.body).to match(/not awaiting moderation/)
      end
    end

    it 'shows the issue summary in the body' do
      expect(mail.body).to match(/#{issue.summary}/)
    end

    context 'issue with HTML special characters in the summary' do
      let (:issue) { Issue.make! :summary => '< & >' }

      it 'does not HTML-escape the summary, as the email is text/plain' do
        expect(mail.body).to match(/< & >/)
      end
    end

    it 'shows the issue description in the body' do
      expect(mail.body).to match(/#{issue.description}/)
    end

    context 'issue with HTML special characters in the body' do
      let (:issue) { Issue.make! :description => '<!-- hey -->' }

      it 'does not HTML-escape the description, as the email is text/plain' do
        expect(mail.body).to match(/<!-- hey -->/)
      end
    end

    it 'includes a link to the administator dashboard' do
      expect(mail.body).to match(/#{admin_dashboard_url}/)
    end

    it 'includes a link to the issue edit form' do
      expect(mail.body).to match(/#{edit_issue_url(issue)}/)
    end

    it 'includes "support@wincent.com" in the Message-ID header' do
      expect(mail.header['message-id'].to_s).to match(%r{\A<.+support@wincent.com>\z})
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      expect(mail.header['return-path'].to_s).to match(/#{Regexp.escape APP_CONFIG['support_email']}/)
    end

    it 'creates a corresponding Message object' do
      message = Message.find_by_message_id_header(mail.header['message-id'].to_s)
      expect(message.related).to eq(issue)
    end
  end
end
