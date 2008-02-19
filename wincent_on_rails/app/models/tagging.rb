class Tagging < ActiveRecord::Base
  belongs_to  :tag, :counter_cache => true
  belongs_to  :taggable, :polymorphic => true

  # Expects an actual Tag instance.
  def self.grouped_taggings_for_tag tag
    taggings = {}
    # not really "grouped" in the SQL sense (GROUP BY); rather, ordered
    find_all_by_tag_id(tag.id, :order => 'taggable_type').each do |t|
      if taggings[t.taggable_type].nil?
        taggings[t.taggable_type] = [t]
      else
        taggings[t.taggable_type] << t
      end
    end
    taggings
  end

  # Expects an array of tag names (String objects).
  def self.grouped_taggings_for_tag_names tags
    # first get the tags
    query = []
    tags.length.times { query << 'name = ?' }
    query = query.join ' OR '
    @tags = {}
    @tags[:found]     = Tag.find(:all, :conditions => [query, *tags])
    @tags[:not_found] = tags - (@tags[:found].collect {|t| t.name})

    # now get taggings which feature those tags
    if @tags[:found].length > 0
      tag_ids = @tags[:found].collect { |t| t.id}
      query = []
      tag_ids.length.times { query << 'tag_id = ?' }
      query = <<-QUERY
        SELECT    COUNT(*) AS tag_count, taggable_id, taggable_type
        FROM      taggings
        WHERE     #{query.join ' OR '}
        GROUP BY  taggable_id, taggable_type
        ORDER BY  taggable_type
      QUERY

      # here we require that each taggable have _all_ the tags in order to survive
      # an alternative would be to accept all and order them from highest count to lowest in the search results
      taggings = Tagging.find_by_sql([query, *tag_ids]).reject { |t| t.tag_count.to_i < tag_ids.length }
      @taggings = {}
      taggings.each do |t|
        if @taggings[t.taggable_type].nil?
          @taggings[t.taggable_type] = [t]
        else
          @taggings[t.taggable_type] << t
        end
      end
    end
    [@tags, @taggings || {}]
  end
end
