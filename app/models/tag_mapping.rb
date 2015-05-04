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
      # for each record
      # find records with tag_name
      # update them to use canonical name instead
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
