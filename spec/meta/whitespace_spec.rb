require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Source code files' do
  module Wincent
    Dir.chdir File.join(File.dirname(__FILE__), '..', '..') do
      SOURCE_FILES = Dir['app/**/*'] +
                     Dir['config/**/*'] +
                     Dir['db/migrate/*'] +
                     Dir['lib/**/*'] +
                     Dir['spec/**/*']
      SOURCE_FILES.reject! do |path|
        case path
        when 'spec/mailers/support_mailer_spec.rb' # sample email with trailing space
          true
        else
          !path.match(/\.(builder|erb|haml|rake|rb)\Z/)
        end
      end
    end
  end

  before :all do
    @pwd = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), '..', '..')
  end

  after :all do
    Dir.chdir @pwd
  end

  def check_file file, regex
    bad_lines = []
    File.readlines(file).each_with_index do |line, index|
      if line.match(regex)
        bad_lines << index + 1
      end
    end
    bad_lines
  end

  RSpec::Matchers.define :have_trailing_whitespace do
    match do |given|
      @bad_lines = check_file given, /\s+\n$/
      !@bad_lines.empty?
    end

    failure_message_for_should do |given|
      "expected #{given.inspect} to have trailing whitespace but it did not"
    end

    failure_message_for_should_not do |given|
      "expected #{given.inspect} to not have trailing whitespace but " +
        "trailing whitespace found on line(s) #{@bad_lines.join(', ')}"
    end
  end

  RSpec::Matchers.define :contain_tabs do
    match do |given|
      @bad_lines = check_file given, /[\t\v]/
      !@bad_lines.empty?
    end

    failure_message_for_should do |given|
      "expected #{given.inspect} to contain tabs but it did not"
    end

    failure_message_for_should_not do |given|
      "expected #{given.inspect} to not contain tabs but tabs found on " +
        "line(s) #{@bad_lines.join(', ')}"
    end
  end

  RSpec::Matchers.define :have_newline_at_end_of_file do
    match do |given|
      begin
        f = File.new(given)
        f.seek(-1, IO::SEEK_END)
        success = f.readchar == "\n".unpack('c').first
      rescue Errno::EINVAL
        # most likely a zero-byte file
        success = true
      end
      success
    end

    failure_message_for_should do |given|
      "expected #{given.inspect} to have a newline at the end of file but " +
        "it did not"
    end

    failure_message_for_should_not do |given|
      "expected #{given.inspect} not to have a newline at the end of file " +
        "but it did"
    end
  end

  Wincent::SOURCE_FILES.each do |file|
    describe file do
      it 'contains no trailing whitespace' do
        file.should_not have_trailing_whitespace
      end

      it 'contains no tabs' do
        file.should_not contain_tabs
      end

      it 'has a newline at the end' do
        file.should have_newline_at_end_of_file
      end
    end
  end
end
