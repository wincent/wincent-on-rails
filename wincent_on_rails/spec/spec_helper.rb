# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

include FixtureReplacement

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
end

module Spec
  module Rails
    module Matchers
      class FailValidationFor # :nodoc:
        def initialize attribute
          @attribute = attribute
        end

        def matches? model
          @model = model
          !@model.valid? and !@model.errors.on(@attribute).nil?
        end

        def failure_message
          "expected to fail validation with errors on #{@attribute} but was #{self.valid}; #{self.errors}"
        end

        def negative_failure_message
          "expected to pass validation with no errors on #{@attribute} but was #{self.valid}; #{self.errors}"
        end

        def description
          "fail validation for attribute #{@attribute}"
        end

        def valid
          if @model.valid? then 'valid' else 'invalid' end
        end

        def errors
          if @model.valid? then 'no errors' else @model.errors.full_messages.to_sentence end
        end
      end # class FailValidationFor

      def fail_validation_for attribute
        FailValidationFor.new attribute
      end
    end # module Matchers
  end # module Rails
end # module Spec
