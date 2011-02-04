require 'rspec/core/formatters/base_text_formatter'
require 'spec/support/formatter_helpers'

# Format spec results for display in the Vim quickfix window
# Use this custom formatter like this:
#   bin/rspec -r spec/support/vim_formatter -f RSpec::Core::Formatters::VimFormatter spec
module RSpec
  module Core
    module Formatters
      class VimFormatter < BaseTextFormatter
        include FormatterHelpers

        # TODO: vim-side function for printing progress (if that's even possible)

        def example_failed example
          exception = example.execution_result[:exception]
          path = exception.backtrace.find do |frame|
            frame =~ %r{\bspec/.*_spec\.rb:\d+\z}
          end
          message = format_message exception.message
          path    = format_caller path
          output.puts "#{path}: [FAIL] #{message}" if path
        end

        def example_pending example
          message = format_message example.execution_result[:pending_message]
          path    = format_caller example.location
          output.puts "#{path}: [PEND] #{message}" if path
        end

        def dump_failures *args; end

        def dump_pending *args; end

        # suppress messages like:
        #   Run filtered using {:focus=>true}
        def message msg; end

        # like BaseFormatter
        def dump_summary duration, example_count, failure_count, pending_count
          @duration = duration
          @example_count = example_count
          @failure_count = failure_count
          @pending_count = pending_count
        end

      private

        def format_message msg
          # NOTE: may consider compressing all whitespace here
          msg.gsub("\n", ' ')[0,40]
        end
      end # class VimFormatter
    end # module Formatter
  end # module Runner
end # module Spec
