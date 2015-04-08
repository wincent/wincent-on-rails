require 'spec_helper'

describe ResetMailer do
  describe 'reset message' do
    before do
      @administrator  = 'win@wincent.com'
      @support        = 'support@wincent.com'
      @reset          = Reset.make!
      @recipient      = @reset.email.address
      @mail           = ResetMailer.reset_message @reset
    end

    it 'has content-type "text/plain"' do
      expect(@mail.content_type).to match(%r{text/plain}) # ignore charset
    end

    it 'sets the subject line' do
      expect(@mail.subject).to match(/forgotten passphrase/)
    end

    it 'is addressed to the recipient' do
      expect(@mail.to.length).to eq(1)
      expect(@mail.to.first).to eq(@recipient)
    end

    it "is BCC'ed to the administrator" do
      expect(@mail.bcc.length).to eq(1)
      expect(@mail.bcc.first).to eq(@administrator)
    end

    it 'is from the administrator' do
      # the administrator will receive bounce messages and so can keep an eye on abuse
      expect(@mail.from.length).to eq(1)
      expect(@mail.from.first).to eq(@support)
    end

    it 'mentions the reset address in the body' do
      expect(@mail.body).to match(/#{@recipient}/)
    end

    it 'includes the (short) reset link in the body' do
      expect(@mail.body).to match(/#{reset_url(@reset)}/)
    end

    it 'does not include the (long) edit reset link in the body' do
      expect(@mail.body).not_to match(/#{edit_reset_url(@reset)}/)
    end

    it 'mentions the cutoff date in UTC time' do
      expect(@mail.body).to match(/#{@reset.cutoff.utc.to_s}/)
    end

    it 'includes "support@wincent.com" in the Message-ID header' do
      expect(@mail.header['message-id'].to_s).to match(%r{\A<.+support@wincent.com>\z})
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      expect(@mail.header['return-path'].to_s).to match(/#{Regexp.escape @support}/)
    end

    it 'creates a corresponding Message object' do
      message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
      expect(message.related).to eq(@reset)
    end
  end
end
