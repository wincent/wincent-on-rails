require 'spec/story/runner/scenario_collector.rb'
require 'spec/story/runner/scenario_runner.rb'
require 'spec/story/runner/story_runner.rb'
require 'spec/story/runner/story_parser.rb'
require 'spec/story/runner/story_mediator.rb'
require 'spec/story/runner/plain_text_story_runner.rb'

module Spec
  module Story
    module Runner
      class << self
        def run_options # :nodoc:
          @run_options ||= ::Spec::Runner::OptionParser.parse(ARGV, $stderr, $stdout)
        end
        
        def story_runner # :nodoc:
          unless @story_runner
            @story_runner = StoryRunner.new(scenario_runner, world_creator)
            unless run_options.dry_run
              register_listener(::Spec::Story::Reporter::PlainTextReporter.new($stdout))
            end
            unless run_options.formatters.empty?
              register_listener(::Spec::Story::Documenter::PlainTextDocumenter.new($stdout))
            end
            Runner.register_exit_hook
          end
          @story_runner
        end
        
        def scenario_runner # :nodoc:
          @scenario_runner ||= ScenarioRunner.new
        end
        
        def world_creator # :nodoc:
          @world_creator ||= World
        end
        
        # Use this to register a customer output formatter.
        def register_listener(listener)
          story_runner.add_listener(listener)
          world_creator.add_listener(listener)
          scenario_runner.add_listener(listener)
        end
        
        def register_exit_hook # :nodoc:
          # TODO - when story runner uses test/unit runners like example runner does we can kill
          # this and also the assorted Kernel.stub!(:at_exit) in examples
          at_exit do
            Runner.story_runner.run_stories unless $!
          end
          # TODO exit with non-zero status if run fails
        end
        
        def dry_run
          run_options.dry_run
        end
        
      end
    end
  end
end
