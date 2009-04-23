module Wincent
  module ActiveRecord
    module ErrorExtensions
      def flashable_error_string
        errors.full_messages.join(', ')
      end
    end
  end
end

ActiveRecord::Base.send(:include, Wincent::ActiveRecord::ErrorExtensions)
