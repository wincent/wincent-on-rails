module RSpec
  module Matchers
    class FailValidationFor # :nodoc:
      def initialize attribute
        @attribute = attribute
      end

      def matches? model
        @model = model
        !@model.valid? and !@model.errors[@attribute].empty?
      end

      def failure_message
        "expected to fail validation with errors on #{@attribute} but was #{self.valid}; #{self.errors}"
      end

      def failure_message_when_negated
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
end # module RSpec
