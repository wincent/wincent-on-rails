require File.expand_path('../spec_helper', File.dirname(__FILE__))

def sample_email name
  path = File.dirname(__FILE__) + '/../fixtures/mail/' + name
  IO.read(path)
end

describe SupportMailer do
  it 'should process incoming support requests'
end

describe SupportMailer, 'regressions' do
  it 'should handle incoming mails without valid "To" headers' do
    lambda { SupportMailer.receive sample_email('real/dodgy-to-header') }.should_not raise_error
  end

  it 'should handle incoming mails without "To" headers' do
    lambda { SupportMailer.receive sample_email('fake/no-to-header') }.should_not raise_error
  end

  it 'should handle incoming mails without valid "From" headers' do
    lambda { SupportMailer.receive sample_email('fake/dodgy-from-header') }.should_not raise_error
  end

  it 'should handle incoming mails without "From" headers' do
    lambda { SupportMailer.receive sample_email('fake/no-from-header') }.should_not raise_error
  end
end
