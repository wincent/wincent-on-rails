require 'rspec/core/formatters/progress_formatter'
require 'spec/support/formatter_helpers'

# Use this custom formatter like this:
#   bin/rspec -r spec/support/growl_formatter.rb -f RSpec::Core::Formatters::GrowlFormatter spec
# Or by adding the options to the .rspec file:
#   -r spec/support/growl_formatter
#   -f RSpec::Core::Formatters::GrowlFormatter
module RSpec
  module Core
    module Formatters
      class GrowlFormatter < ProgressFormatter
        include FormatterHelpers
      end # class GrowlFormatter
    end # module Formatter
  end # module Runner
end # module Spec
