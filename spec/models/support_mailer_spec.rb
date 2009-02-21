require File.dirname(__FILE__) + '/../spec_helper'

describe SupportMailer do
  it 'should process incoming support requests'
end

describe SupportMailer, 'regressions' do
  before do
    @mail = TMail::Mail.new
    @mail.from      = 'foo@example.com'
    @mail.to        = 'bar@example.com'
    @mail.subject   = '$$$$'
    @mail.body      = 'Hello, world'
  end

  it 'should handle incoming mails without "To" headers' do
    pending
    # doesn't work: bails with a very unhelpful stack trace:
    #    undefined method `index' for #<TMail::Mail:0x21880b0>
    #   ./spec/models/support_mailer_spec.rb:9:
    @mail.to = nil
    SupportMailer.receive @mail
  end

  it 'should handle incoming mails without "From" headers'
end
