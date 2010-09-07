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
      @mail.content_type.should =~ %r{text/plain} # ignore charset
    end

    it 'sets the subject line' do
      @mail.subject.should =~ /forgotten passphrase/
    end

    it 'is addressed to the recipient' do
      @mail.to.length.should == 1
      @mail.to.first.should == @recipient
    end

    it "is BCC'ed to the administrator" do
      @mail.bcc.length.should == 1
      @mail.bcc.first.should == @administrator
    end

    it 'is from the administrator' do
      # the administrator will receive bounce messages and so can keep an eye on abuse
      @mail.from.length.should == 1
      @mail.from.first.should == @support
    end

    it 'mentions the reset address in the body' do
      @mail.body.should match(/#{@recipient}/)
    end

    it 'includes the (short) reset link in the body' do
      @mail.body.should match(/#{reset_url(@reset)}/)
    end

    it 'does not include the (long) edit reset link in the body' do
      @mail.body.should_not match(/#{edit_reset_url(@reset)}/)
    end

    it 'mentions the cutoff date in UTC time' do
      @mail.body.should match(/#{@reset.cutoff.utc.to_s}/)
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
      message.related.should == @reset
    end
  end
end
