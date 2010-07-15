require 'rspec/core/formatters/base_formatter'
require 'rspec/core/formatters/base_text_formatter'
require 'pathname'

# Format spec results for display in the Vim quickfix window
# Use this custom formatter like this:
#   bin/rspec -r spec/support/vim_formatter.rb -f RSpec::Core::Formatters::VimFormatter spec
module RSpec
  module Core
    module Formatters
      class VimFormatter < BaseTextFormatter

        # TODO: handle pending issues
        # TODO: vim-side function for printing progress
        def dump_failures
          failed_examples.each do |failure|
            exception = failure.execution_result[:exception_encountered]
            path = exception.backtrace.find do |frame|
              frame =~ %r{\bspec/.*_spec\.rb:\d+\z}
            end
            message = exception.message.gsub("\n", ' ')[0,40]
            output.puts "#{relativize_path(path)}: #{message}" if path
          end
        end

        def dump_summary; end

        def dump_pending; end

        def close
          # summary_line example_count, failure_count, pending_count
          # growlnotify here
          super
        end

      private

        def relativize_path path
          @wd ||= Pathname.new Dir.getwd
          begin
            return Pathname.new(path).relative_path_from(@wd)
          rescue ArgumentError
            # raised unless both paths relative, or both absolute
            return path
          end
        end
      end # class VimFormatter
    end # module Formatter
  end # module Runner
end # module Spec
