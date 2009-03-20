require File.dirname(__FILE__) + '/../spec_helper'

describe ConfirmationMailer, 'confirmation' do
  include ActionController::UrlWriter
  default_url_options[:host] = APP_CONFIG['host']
  default_url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443

  before do
    @administrator  = 'win@wincent.com'
    @confirmation   = create_confirmation
    @mail           = ConfirmationMailer.create_confirmation_message @confirmation
  end

  it 'should set the subject line' do
    @mail.subject.should =~ /confirm your email address/
  end

  it 'should be addressed to the recipient' do
    @mail.to.length.should == 1
    @mail.to.first.should == @confirmation.email.address
  end

  it "should be BCC'ed to the administrator" do
    @mail.bcc.length.should == 1
    @mail.bcc.first.should == @administrator
  end

  it 'should be from the administrator' do
    # the administrator will receive bounce messages and so can keep an eye on abuse
    @mail.from.length.should == 1
    @mail.from.first.should == @administrator
  end

  it 'should mention the confirmation address in the body' do
    @mail.body.should match(/#{@confirmation.email.address}/)
  end

  it 'should include the confirmation link in the body' do
    @mail.body.should match(/#{confirmation_url(@confirmation)}/)
  end

  it 'should mention the cutoff date in UTC time' do
    @mail.body.should match(/#{@confirmation.cutoff.utc.to_s}/)
  end

  it 'should include "support@wincent.com" in the Message-ID header' do
    @mail.header['message-id'].to_s.should =~ %r{\A<.+support@wincent.com>\z}
  end

  it 'should create a corresponding Message object' do
    message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
    message.related.should == @confirmation
  end
end
