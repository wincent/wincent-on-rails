# Convenience methods added to invoke Factory Girl factories by sending
# messages directly to ActiveRecord classes.
class ActiveRecord::Base
  class << self
    # Wrapper for FactoryGirl.build
    def make(overrides = {}, &block)
      instance = FactoryGirl.build name.underscore, overrides
      yield instance if block_given?
      instance
    end

    # Wrapper for FactoryGirl.create
    def make!(overrides = {}, &block)
      instance = FactoryGirl.create name.underscore, overrides
      yield instance if block_given?
      instance
    end

    # Wrapper for FactoryGirl.attributes_for
    def valid_attributes(overrides = {}, &block)
      attrs = FactoryGirl.attributes_for name.underscore, overrides
      attrs = yield attrs if block_given?
      attrs
    end

    # Wrapper for FactoryGirl.build_stubbed
    def stub(overrides = {}, &block)
      instance = FactoryGirl.build_stubbed name.underscore, overrides
      yield instance if block_given?
      instance
    end
  end
end

if FactoryGirl.factories.none?
  FactoryGirl.find_definitions
end
