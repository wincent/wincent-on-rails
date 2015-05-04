class TagMappingObserver < ActiveRecord::Observer
  def after_destroy(tag_mapping)
    invalidate_cache
  end

  # Handles both create and update.
  def after_save(tag_mapping)
    invalidate_cache
  end

private

  def invalidate_cache
    Rails.cache.delete(TagMapping::CACHE_KEY)
  end
end # class TagMappingObserver
