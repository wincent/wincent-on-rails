module ActiveRecord
  class Base
    def flashable_error_string
      errors.full_messages.join(', ')
    end
  end
end
