require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'

describe ExceptionMailer, 'exception report' do
  before do
    @exception = RuntimeError.new 'Reactor meltdown'
    @exception.stub!(:backtrace).and_return(['foo', 'bar', 'baz'])
    @controller = Object.new
    @controller.stub!(:controller_name).and_return('cartons')
    @controller.stub!(:action_name).and_return('destroy')
    @request = Object.new
    @request.stub!(:protocol).and_return('https://')
    @request.stub!(:request_uri).and_return('/cartons/xxl')
    @mail = ExceptionMailer.create_exception_report @exception, @controller, @request
  end

  it 'should set the subject line' do
    @mail.subject.should == "[ERROR] #{APP_CONFIG['host']} cartons\#destroy (RuntimeError: Reactor meltdown)"
  end

  it 'should be addressed to the administrator' do
    @mail.to.length.should == 1
    @mail.to.first.should == APP_CONFIG['admin_email']
  end

  it 'should be from the administrator' do
    @mail.from.length.should == 1
    @mail.from.first.should == APP_CONFIG['admin_email']
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
    @mail.body.should match(/  foo\n  bar\n  baz/)
  end
end
