require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Source code files' do
  module Wincent
    Dir.chdir File.join(File.dirname(__FILE__), '..', '..') do
      SOURCE_FILES = Dir['app/**/*'] +
                     Dir['config/**/*'] +
                     Dir['db/example_data.rb'] +
                     Dir['db/migrate/*'] +
                     Dir['features/**/*'] +
                     Dir['lib/**/*'] +
                     Dir['spec/**/*']
      SOURCE_FILES.reject! do |path|
        case path
        when 'features/support/env.rb',
             'features/support/paths.rb',
             'features/support/version_check.rb',
             'lib/tasks/cucumber.rake'
          # whitespace-damaged files from Cucumber, updated every release
          true
        else
          !path.match(/\.(builder|erb|haml|rake|rb)\Z/)
        end
      end
    end
  end

  before(:all) do
    @pwd = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), '..', '..')
  end

  after(:all) do
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

  def have_trailing_whitespace
    simple_matcher('have trailing whitespace') do |given, matcher|
      bad_lines                         = check_file given, /\s+\n$/
      matcher.failure_message           = "expected #{given.inspect} to have trailing whitespace but it did not"
      matcher.negative_failure_message  = "expected #{given.inspect} to not have trailing whitespace " +
                                          "but trailing whitespace found on line(s) #{bad_lines.join(', ')}"
      !bad_lines.empty?
    end
  end

  def contain_tabs
    simple_matcher('contain tabs') do |given, matcher|
      bad_lines                         = check_file given, /[\t\v]/
      matcher.failure_message           = "expected #{given.inspect} to contain tabs but it did not"
      matcher.negative_failure_message  = "expected #{given.inspect} to not contain tabs " +
                                          "but tabs found on line(s) #{bad_lines.join(', ')}"
      !bad_lines.empty?
    end
  end

  def have_newline_at_end_of_file
    simple_matcher('have newline at end of file') do |given, matcher|
      matcher.failure_message           = "expected #{given.inspect} to have a newline at the end of file but it did not"
      matcher.negative_failure_message  = "expected #{given.inspect} not to have a newline at the end of file but it did"
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
  end

  Wincent::SOURCE_FILES.each do |file|
    describe file do
      it 'should not have trailing whitespace' do
        file.should_not have_trailing_whitespace
      end

      it 'should not contain tabs' do
        file.should_not contain_tabs
      end

      it 'should have a newline at the end of the file' do
        file.should have_newline_at_end_of_file
      end
    end
  end
end
