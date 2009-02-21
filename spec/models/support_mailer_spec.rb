require File.dirname(__FILE__) + '/../spec_helper'

def sample_email name
  path = File.dirname(__FILE__) + '/../fixtures/mail/' + name
  IO.read(path)
end

describe SupportMailer do
  it 'should process incoming support requests'
end

describe SupportMailer, 'regressions' do
  it 'should handle incoming mails without valid "To" headers' do
    # this one wasn't missing the "To" header, it was just horribly mangled:
    #   "@@TO_NAME" <@@TO_EMAIL>
    lambda { SupportMailer.receive sample_email('dodgy-to-header') }.should_not raise_error
  end

  it 'should handle incoming mails without "From" headers'
end
