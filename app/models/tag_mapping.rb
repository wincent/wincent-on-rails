# No UI for this for now; just console:
#
#   TagMapping.alias('mac.os.x', 'os.x') # alias old -> canonical
#
# Then, to update existing records:
#
#   TagMapping.canonicalize!
#
class TagMapping < ActiveRecord::Base
  attr_accessible :canonical_tag_name, :tag_name

  CACHE_KEY = 'TagMapping.mappings'

  class << self
    def alias(old, canonical)
      create(tag_name: old, canonical_tag_name: canonical)
    end

    def canonicalize!
      mappings.each do |tag_name, canonical_tag_name|
        break unless old_tag = Tag.find_by(name: tag_name)
        break unless Tagging.joins(:tag).where(tags: { name: tag_name }).any?

        new_tag = Tag.find_or_create_by!(name: canonical_tag_name)
        Tagging.joins(:tag).where(tags: { name: tag_name }).find_each do |tagging|
          begin
            tagging.update_attribute(:tag_id, new_tag.id)
          rescue ActiveRecord::RecordNotUnique
            # It would be a dupe, so just remove it. Reset the tag_id to its
            # former value or Rails will update the counter cache on the wrong
            # record.
            tagging.tag_id = old_tag.id
            tagging.destroy
          end
        end
      end
    end

    # Returns all mappings, as a hash table for ease of use.
    def mappings
      Rails.cache.fetch(CACHE_KEY) do
        select(:tag_name, :canonical_tag_name).inject({}) do |acc, rec|
          acc[rec.tag_name] = rec.canonical_tag_name
          acc
        end
      end
    end
  end
end
