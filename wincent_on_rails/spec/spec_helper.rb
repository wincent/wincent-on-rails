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

# used in controller specs
def login_as user
  controller.instance_eval { @current_user = user }
  controller.stub!(:login_before).and_return(nil)   # don't let the before filter clear the user again
end

# used in controller specs
def login_as_admin
  controller.instance_eval do
    @current_user = User.find_by_superuser(true)
    raise if @current_user.nil?
  end
  controller.stub!(:login_before).and_return(nil)   # don't let the before filter clear the user again
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

      class AllowMassAssignmentOf # :nodoc:
        def initialize hash = nil
          raise if hash.nil?
          raise unless hash.kind_of? Hash
          raise unless hash.length > 0
          @attributes = hash
        end

        def matches? model
          old = {}
          @attributes.each do |key, val|
            current = model.send(key.to_s)
            raise if val == current
            old[key] = current
          end
          raise unless model.update_attributes(@attributes)
          @attributes.keys.all? do |key|
            model.send(key.to_s) != old[key]
          end
        end

        def failure_message
          "expected mass assignment to #{self.keys_as_string} to succeed but it did not"
        end

        def negative_failure_message
          "expected mass assignment to #{self.keys_as_string} to fail but it did not"
        end

        def description
          "allow mass assignment to #{self.keys_as_string}"
        end

        def keys_as_string
          @attributes.keys.join(', ')
        end
      end # class AllowMassAssignmentFor

      def allow_mass_assignment_of hash = nil
        AllowMassAssignmentOf.new hash
      end
    end # module Matchers
  end # module Rails
end # module Spec
