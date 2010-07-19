require 'rspec/core/formatters/base_formatter'
require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/progress_formatter'

# Use this custom formatter like this:
#   bin/rspec -r spec/support/growl_formatter.rb -f RSpec::Core::Formatters::GrowlFormatter spec
# Or by adding the options to the .rspec file:
#   -r spec/support/growl_formatter.rb
#   -f RSpec::Core::Formatters::GrowlFormatter
module RSpec
  module Core
    module Formatters
      class GrowlFormatter < ProgressFormatter
        def close
          super
          summary = summary_line example_count, failure_count, pending_count
          if failure_count > 0
            growlnotify "--image ./autotest/fail.png -p Emergency -m '#{summary}' -t 'Spec failure detected'"
          elsif pending_count > 0
            growlnotify "--image ./autotest/pending.png -p High -m '#{summary}' -t 'Pending spec(s) present'"
          else
            growlnotify "--image ./autotest/pass.png -p 'Very Low' -m '#{summary}' -t 'All specs passed'"
          end
        end

      private

        def growlnotify str
          system 'which growlnotify > /dev/null'
          if $?.exitstatus == 0
            system "growlnotify -n autotest #{str}"
          end
        end
      end # class VimFormatter
    end # module Formatter
  end # module Runner
end # module Spec