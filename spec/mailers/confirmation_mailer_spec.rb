require 'spec_helper'

describe ConfirmationMailer do
  describe 'confirmation message' do
    before do
      @administrator  = 'win@wincent.com'
      @support        = 'support@wincent.com'
      @confirmation   = Confirmation.make!
      @mail           = ConfirmationMailer.confirmation_message @confirmation
    end

    it 'has content-type "text/plain"' do
      @mail.content_type.should =~ %r{text/plain} # ignore charset
    end

    it 'sets the subject line' do
      @mail.subject.should =~ /confirm your email address/
    end

    it 'is addressed to the recipient' do
      @mail.to.length.should == 1
      @mail.to.first.should == @confirmation.email.address
    end

    it "is BCC'ed to the administrator" do
      @mail.bcc.length.should == 1
      @mail.bcc.first.should == @administrator
    end

    it 'is from the support address' do
      @mail.from.length.should == 1
      @mail.from.first.should == @support
    end

    it 'mentions the confirmation address in the body' do
      @mail.body.should match(/#{@confirmation.email.address}/)
    end

    it 'includes the confirmation link in the body' do
      @mail.body.should match(/#{confirmation_url(@confirmation)}/)
    end

    it 'mentions the cutoff date in UTC time' do
      @mail.body.should match(/#{@confirmation.cutoff.utc.to_s}/)
    end

    it 'includes "support@wincent.com" in the Message-ID header' do
      @mail.header['message-id'].to_s.should =~ %r{\A<.+support@wincent.com>\z}
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      @mail.header['return-path'].to_s.should =~ /#{Regexp.escape @support}/
    end

    it 'creates a corresponding Message object' do
      message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
      message.related.should == @confirmation
    end
  end
end
