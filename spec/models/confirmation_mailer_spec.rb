require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'
describe ConfirmationMailer, 'confirmation' do
  before do
    request         = OpenStruct.new
    request.host    = 'example.com'
    request.port    = 80
    @administrator  = 'win@wincent.com'
    @confirmation   = create_confirmation
    @mail           = ConfirmationMailer.create_confirmation_message @confirmation, request
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
    pending
    # for some reason, this tries to evaluate nil.email_confirm_url
    @mail.body.should match(email_confirm_url(@confirmation.email, @confirmation)) # :host => 'wincent.com'
  end

  it 'should mention the cutoff date in UTC time' do
    @mail.body.should match(/#{@confirmation.cutoff.utc.to_s}/)
  end

end
