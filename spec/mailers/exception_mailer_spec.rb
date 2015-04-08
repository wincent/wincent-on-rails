require 'spec_helper'

describe ExceptionMailer do
  describe 'exception report' do
    before do
      @root = Rails.root
      @exception = RuntimeError.new 'Reactor meltdown'
      backtrace = %w(foo bar baz).map { |frame| (@root + frame).to_s }
      stub(@exception).backtrace { backtrace }
      @controller = stub!.controller_name { 'cartons' }.subject
      stub(@controller).action_name { 'destroy' }
      @request = stub!.url { 'https://localhost/cartons/xxl' }.subject
      stub(@request).remote_ip { '127.0.0.1' }
      stub(@request).session {{ 'session_id' => 'deadbeef'}}
      stub(@request).filtered_parameters { "{:a => 'foo'}" }
      stub(@request).filtered_env {{'a' => 'foo'}}
      @mail = ExceptionMailer.exception_report @exception, @controller, @request
    end

    it 'has content-type "text/plain"' do
      expect(@mail.content_type).to match(%r{text/plain}) # ignore charset
    end

    it 'sets the subject line' do
      expect(@mail.subject).to eq("[ERROR] #{APP_CONFIG['host']} cartons\#destroy (RuntimeError: Reactor meltdown)")
    end

    it 'is addressed to the administrator' do
      expect(@mail.to.length).to eq(1)
      expect(@mail.to.first).to eq(APP_CONFIG['admin_email'])
    end

    it 'is from the support address' do
      expect(@mail.from.length).to eq(1)
      expect(@mail.from.first).to eq(APP_CONFIG['support_email'])
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      expect(@mail.header['return-path'].to_s).to match(/#{Regexp.escape APP_CONFIG['support_email']}/)
    end

    it 'contains the exception class' do
      expect(@mail.body).to match(/Exception: RuntimeError/)
    end

    it 'contains the controller and action' do
      expect(@mail.body).to match(/Controller#action: cartons#destroy/)
    end

    it 'contains the request URL' do
      expect(@mail.body).to match(%r{URL: https://localhost/cartons/xxl})
    end

    it 'contains the exception message' do
      expect(@mail.body).to match(/Message: Reactor meltdown/)
    end

    it 'contains the time' do
      expect(@mail.body).to match(/Time: .+/)
    end

    it 'contains the backtrace' do
      expect(@mail.body).to match(%r{  RAILS_ROOT/foo\n  RAILS_ROOT/bar\n  RAILS_ROOT/baz})
    end

    it 'shows the full expansion of RAILS_ROOT' do
      path_regex = /RAILS_ROOT\s+=\s+#{Regexp.escape @root.to_s}/
      expect(@mail.body).to match(path_regex)
    end

    it 'shows the full expansion of BUNDLE_PATH' do
      path_regex = /BUNDLE_PATH\s+=\s+#{Regexp.escape Bundler.bundle_path.to_s}/
      expect(@mail.body).to match(path_regex)
    end
  end
end
