# Generate a string of 10 random lowercase letters
Sham.random do |n|
  chars = ('a'..'z').to_a
  length = chars.length
  Array.new(10) { chars[rand(length)] }.join
end

Sham.random_first_name do |n|
  names = %w{Jacob Isabella Ethan Emma Michael Olivia Alexander Sophia William
    Ava Joshua Emily Daniel Madison Jayden Abigail Noah Chloe Anthony Mia}
  length = names.length
  names[rand(length)]
end

Sham.random_last_name do |n|
  names = %w{Lee Smith Long Martin Brown Roy Tremblay McGraw Gagnon Wilson
    Clark Johnson White Williams Taylor Campbell Anderson Chan Jones}
  length = names.length
  names[rand(length)]
end

# Convenience methods added to invoke Factory Girl factories by sending
# messages directly to ActiveRecord classes.
#
# We use these rather than the one provided by Factory Girl itself
# (factory_girl/syntax/make) because we want wrappers for all four methods,
# not just "create", and we also want the option of customising the returned
# instance via a block.
class ActiveRecord::Base
  module FactoryGirl
    module Forwarder
      def self.delegate method, model, attributes, &block
        instance = Factory.send method, model.to_s.underscore.to_sym, attributes
        yield instance if block_given?
        instance
      end
    end
  end

  # Wrapper for Factory.build
  def self.make attributes = {}, &block
    FactoryGirl::Forwarder.delegate :build, self, attributes, &block
  end

  # Wrapper for Factory.create
  def self.make! attributes = {}, &block
    FactoryGirl::Forwarder.delegate :create, self, attributes, &block
  end

  # Wrapper for Factory.attributes_for
  def self.valid_attributes attributes = {}, &block
    FactoryGirl::Forwarder.delegate :attributes_for, self, attributes, &block
  end

  # Wrapper for Factory.stub
  def self.stub attributes = {}, &block
    FactoryGirl::Forwarder.delegate :stub, self, attributes, &block
  end
end
