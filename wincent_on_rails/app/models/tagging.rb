class Tagging < ActiveRecord::Base
  belongs_to  :tag, :counter_cache => true
  belongs_to  :taggable, :polymorphic => true

  # Expects an actual Tag instance.
  # If user is a superuser, returns all taggings.
  # If user is a normal user, returns all taggings which are either public or belong to the user.
  # If user is nul, returns only public taggings.
  def self.grouped_taggings_for_tag tag, user
    taggings = {}
    # not really "grouped" in the SQL sense (GROUP BY); rather, ordered
    find_all_by_tag_id(tag.id, :order => 'taggable_type').each do |t|
      # filter out tagged items which user shouldn't have access to
      # could also consider doing this in the initial query
      next unless accessible t, user

      if taggings[t.taggable_type].nil?
        taggings[t.taggable_type] = [t]
      else
        taggings[t.taggable_type] << t
      end
    end
    taggings
  end

  # Expects an array of tag names (String objects).
  # As above, restricts visibility of returned tag objects according to who the current user is.
  def self.grouped_taggings_for_tag_names tags, user
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
        next unless accessible t, user
        if @taggings[t.taggable_type].nil?
          @taggings[t.taggable_type] = [t]
        else
          @taggings[t.taggable_type] << t
        end
      end
    end
    [@tags, @taggings || {}]
  end

private

  def self.accessible tagging, user
    taggable = tagging.taggable
    if user.nil?
      # NOTE: could simplify this by expecting all taggable models to declare both public and user_id
      return false if taggable.respond_to?(:public) and !taggable.public
    elsif !user.superuser
      return false if taggable.respond_to?(:public) and !taggable.public and taggable.user_id != user.id
    end
    true
  end

end
