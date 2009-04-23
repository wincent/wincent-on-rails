module Wincent
  module ActiveRecord
    module ErrorExtensions
      def flashable_error_string
        errors.full_messages.join(', ')
      end
    end
  end
end

if ActiveRecord::Base.instance_methods.include? 'flashable_error_string'
  raise 'ActiveRecord::Base#flashable_error_string already exists'
end
ActiveRecord::Base.send(:include, Wincent::ActiveRecord::ErrorExtensions)
