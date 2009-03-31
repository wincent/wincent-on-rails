# This is a vanilla module rather than being ActiveRecord::Acts::Commentable
# as it is intended to be used via the :extend option when defining associations.
module Commentable
  # All public comments which have passed moderation.
  def published
    find :all, :conditions => { :awaiting_moderation => false, :public => true }
  end

  # Returns all comments for this record which haven't yet been moderated.
  def unmoderated
    find :all, :conditions => { :awaiting_moderation => true }
  end

  # All comments which have not been flagged as spam (both moderated and unmoderated).
  def ham
    find :all
  end

  # The count of all published (not awaiting moderation) comments.
  def published_count
    count :conditions => 'awaiting_moderation = FALSE AND public = TRUE'
  end

  # The count of comments awaiting moderation.
  def unmoderated_count
    count :conditions => 'awaiting_moderation = TRUE'
  end

  def ham_count
    # TODO: find a way to make a counter_cache-style column in the model database for this value
    # this would be useful in the Posts controller index action, for example
    # at the moment we have no choice but to show the full count (moderated + unmoderated) from the comments counter_cache
    # but it would be nice to instead display the ham count
    # see notes on this below
    count
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
