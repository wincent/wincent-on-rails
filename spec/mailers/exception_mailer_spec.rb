require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'ostruct'

describe ExceptionMailer, 'exception report' do
  before do
    @root = Rails.root
    @exception = RuntimeError.new 'Reactor meltdown'
    @exception.stub!(:backtrace).and_return([@root + 'foo',
                                             @root + 'bar',
                                             @root + 'baz'])
    @controller = Object.new
    @controller.stub!(:controller_name).and_return('cartons')
    @controller.stub!(:action_name).and_return('destroy')
    @request = Object.new
    @request.stub!(:protocol).and_return('https://')
    @request.stub!(:fullpath).and_return('/cartons/xxl')
    @mail = ExceptionMailer.create_exception_report @exception, @controller, @request
  end

  it 'should set the subject line' do
    @mail.subject.should == "[ERROR] #{APP_CONFIG['host']} cartons\#destroy (RuntimeError: Reactor meltdown)"
  end

  it 'should be addressed to the administrator' do
    @mail.to.length.should == 1
    @mail.to.first.should == APP_CONFIG['admin_email']
  end

  it 'should be from the support address' do
    @mail.from.length.should == 1
    @mail.from.first.should == APP_CONFIG['support_email']
  end

  it 'should include a "return-path" header containing "support@wincent.com"' do
    # will be used as "Envelope from" address
    @mail.header['return-path'].to_s.should =~ /#{Regexp.escape APP_CONFIG['support_email']}/
  end

  it 'should contain the exception class' do
    @mail.body.should match(/Exception: RuntimeError/)
  end

  it 'should contain the controller and action' do
    @mail.body.should match(/Controller#action: cartons#destroy/)
  end

  it 'should contain the request URL' do
    @mail.body.should match(%r{URL: https://#{APP_CONFIG['host']}/cartons/xxl})
  end

  it 'should contain the exception message' do
    @mail.body.should match(/Message: Reactor meltdown/)
  end

  it 'should contain the time' do
    @mail.body.should match(/Time: .+/)
  end

  it 'should contain the backtrace' do
    @mail.body.should match(%r{  RAILS_ROOT/foo\n  RAILS_ROOT/bar\n  RAILS_ROOT/baz})
  end

  it 'should show the full expansion of RAILS_ROOT' do
    @mail.body.should match(/RAILS_ROOT = #{Regexp.escape @root}/)
  end
end