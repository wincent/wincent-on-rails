# This is a vanilla module rather than being ActiveRecord::Acts::Commentable
# as it is intended to be used via the :extend option when defining associations.
module Commentable
  # public comments which have passed moderation
  def published
    where :awaiting_moderation => false, :public => true
  end

  # comments which haven't yet been moderated
  def unmoderated
    where :awaiting_moderation => true
  end
end # module Commentable

=begin

Additional "counter caches"

This is how Rails creates standard counter caches:

        if options[:counter_cache]
          cache_column = options[:counter_cache] == true ?
            "#{self.to_s.underscore.pluralize}_count" :
            options[:counter_cache]

          module_eval(
            "after_create '#{reflection.name}.class.increment_counter(\"#{cache_column}\", #{reflection.primary_key_name})" +
            " unless #{reflection.name}.nil?'"
          )

          module_eval(
            "before_destroy '#{reflection.name}.class.decrement_counter(\"#{cache_column}\", #{reflection.primary_key_name})" +
            " unless #{reflection.name}.nil?'"
          )

          module_eval(
            "#{reflection.class_name}.send(:attr_readonly,\"#{cache_column}\".intern) if defined?(#{reflection.class_name}) && #{ref
lection.class_name}.respond_to?(:attr_readonly)"
          )
        end

So _may_ be able to cook up something that also uses callbacks to achieve the same.

=end
