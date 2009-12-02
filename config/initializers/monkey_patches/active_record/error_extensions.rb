module Wincent
  module ActiveRecord
    module ErrorExtensions
      def flashable_error_string
        errors.full_messages.join(', ')
      end
    end
  end
end

Wincent::ActiveRecord::ErrorExtensions.instance_methods.each do |m|
  if ActiveRecord::Base.instance_methods.include? m
    raise "ActiveRecord::Base\##{m} already exists"
  end
end
ActiveRecord::Base.send(:include, Wincent::ActiveRecord::ErrorExtensions)
