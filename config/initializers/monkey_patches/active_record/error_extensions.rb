if ActiveRecord::Base.instance_methods.include? 'flashable_error_string'
  raise 'ActiveRecord::Base\#flashable_error_string already exists'
end

module ActiveRecord
  class Base
    def flashable_error_string
      errors.full_messages.join(', ')
    end
  end # class Base
end # module ActiveRecord
