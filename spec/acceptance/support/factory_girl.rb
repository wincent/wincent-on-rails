# Convenience methods added to invoke Factory Girl factories by sending
# messages directly to ActiveRecord classes.
class ActiveRecord::Base
  def self.make attributes = {}, &block
    instance = Factory.build to_s.underscore.to_sym, attributes
    block_given? ? yield(instance) : instance
  end

  def self.make! attributes = {}, &block
    instance = Factory.create to_s.underscore.to_sym, attributes
    block_given? ? yield(instance) : instance
  end
end
