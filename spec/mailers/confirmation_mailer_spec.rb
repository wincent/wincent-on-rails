require 'spec_helper'

describe ConfirmationMailer do
  describe 'confirmation message' do
    before do
      @administrator  = 'greg@hurrell.net'
      @support        = 'support@wincent.com'
      @confirmation   = Confirmation.make!
      @mail           = ConfirmationMailer.confirmation_message @confirmation
    end

    it 'has content-type "text/plain"' do
      expect(@mail.content_type).to match(%r{text/plain}) # ignore charset
    end

    it 'sets the subject line' do
      expect(@mail.subject).to match(/confirm your email address/)
    end

    it 'is addressed to the recipient' do
      expect(@mail.to.length).to eq(1)
      expect(@mail.to.first).to eq(@confirmation.email.address)
    end

    it "is BCC'ed to the administrator" do
      expect(@mail.bcc.length).to eq(1)
      expect(@mail.bcc.first).to eq(@administrator)
    end

    it 'is from the support address' do
      expect(@mail.from.length).to eq(1)
      expect(@mail.from.first).to eq(@support)
    end

    it 'mentions the confirmation address in the body' do
      expect(@mail.body).to match(/#{@confirmation.email.address}/)
    end

    it 'includes the confirmation link in the body' do
      expect(@mail.body).to match(/#{confirmation_url(@confirmation)}/)
    end

    it 'mentions the cutoff date in UTC time' do
      expect(@mail.body).to match(/#{@confirmation.cutoff.utc.to_s}/)
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
      expect(message.related).to eq(@confirmation)
    end
  end
end
