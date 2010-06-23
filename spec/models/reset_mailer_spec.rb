require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ResetMailer, 'reset' do
  default_url_options[:host] = APP_CONFIG['host']
  default_url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443

  before do
    @administrator  = 'win@wincent.com'
    @support        = 'support@wincent.com'
    user            = create_user
    @email          = user.emails.create(:address => "#{FR::random_string}@example.com")
    @recipient      = @email.address
    @reset          = user.resets.build
    @reset.email    = @email
    @reset.save
    @mail           = ResetMailer.create_reset_message @reset
  end

  it 'should set the subject line' do
    @mail.subject.should =~ /forgotten passphrase/
  end

  it 'should be addressed to the recipient' do
    @mail.to.length.should == 1
    @mail.to.first.should == @recipient
  end

  it "should be BCC'ed to the administrator" do
    @mail.bcc.length.should == 1
    @mail.bcc.first.should == @administrator
  end

  it 'should be from the administrator' do
    # the administrator will receive bounce messages and so can keep an eye on abuse
    @mail.from.length.should == 1
    @mail.from.first.should == @support
  end

  it 'should mention the reset address in the body' do
    @mail.body.should match(/#{@recipient}/)
  end

  it 'should include the reset link in the body' do
    @mail.body.should match(/#{edit_reset_url(@reset)}/)
  end

  it 'should mention the cutoff date in UTC time' do
    @mail.body.should match(/#{@reset.cutoff.utc.to_s}/)
  end

  it 'should include "support@wincent.com" in the Message-ID header' do
    @mail.header['message-id'].to_s.should =~ %r{\A<.+support@wincent.com>\z}
  end

  it 'should include a "return-path" header containing "support@wincent.com"' do
    # will be used as "Envelope from" address
    @mail.header['return-path'].to_s.should =~ /#{Regexp.escape @support}/
  end

  it 'should create a corresponding Message object' do
    message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
    message.related.should == @reset
  end
end
