module ActiveRecord
  class Base
    def update_attribute!(name, value)
      send(name.to_s + '=', value)
      save!
    end
  end # class Base
end # module ActiveRecord
