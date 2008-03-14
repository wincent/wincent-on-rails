class Tagging < ActiveRecord::Base
  belongs_to  :tag, :counter_cache => true
  belongs_to  :taggable, :polymorphic => true

  # Expects an actual Tag instance.
  # If user is a superuser, returns all taggables.
  # If user is a normal user, returns all taggables which are either public or belong to the user.
  # If user is nul, returns only public taggables.
  def self.grouped_taggables_for_tag tag, user
    taggings = {}
    # not really "grouped" in the SQL sense (GROUP BY); rather, ordered
    find_all_by_tag_id(tag.id, :order => 'taggable_type').each do |t|
      if taggings[t.taggable_type].nil?
        taggings[t.taggable_type] = [t]
      else
        taggings[t.taggable_type] << t
      end
    end
    find_and_filter_taggables taggings, user
  end

  # Expects an array of tag names (String objects).
  # As above, restricts visibility of returned taggable objects according to who the current user is.
  def self.grouped_taggables_for_tag_names tag_names, user
    # first get the tags
    taggables         = nil
    query             = []
    tag_names.length.times { query << 'name = ?' }
    query             = query.join ' OR '
    tags              = {}
    tags[:found]      = Tag.find(:all, :conditions => [query, *tag_names])
    tags[:not_found]  = tag_names - (tags[:found].collect(&:name))

    # now get taggings which feature those tags
    if tags[:found].length > 0
      tag_ids = tags[:found].collect(&:id)
      query   = []
      tag_ids.length.times { query << 'tag_id = ?' }
      query = <<-QUERY
        SELECT    COUNT(*) AS tag_count, taggable_id, taggable_type
        FROM      taggings
        WHERE     #{query.join ' OR '}
        GROUP BY  taggable_id, taggable_type
        ORDER BY  taggable_type
      QUERY

      # here we require that each taggable have _all_ the tags in order to survive
      # (an alternative would be to accept all and order them from highest count to lowest in the search results)
      taggings = {}
      unfiltered_taggings = Tagging.find_by_sql([query, *tag_ids]).reject { |t| t.tag_count.to_i < tag_ids.length }
      unfiltered_taggings.each do |t|
        if taggings[t.taggable_type].nil?
          taggings[t.taggable_type] = [t]
        else
          taggings[t.taggable_type] << t
        end
      end
      taggables = find_and_filter_taggables taggings, user
    end
    [tags, taggables || {}]
  end

private

  def self.find_and_filter_taggables taggings, user
    # here we get all the taggable objects to avoid the "n + 1" SELECT problem
    # instead of taggings.length queries, we now do just taggings.keys.length queries (ie. the number of groups)
    # for example: given 3 posts and 10 articles with tag "baz", we do 2 queries instead of 13
    taggables = {}
    taggings.each_key do |key|
      taggables[key] = key.constantize.find_all_by_id(taggings[key].collect(&:taggable_id).uniq).select do |taggable|
        # filter out tagged items which user shouldn't have access to
        accessible taggable, user
      end
    end
    taggables
  end

  def self.accessible taggable, user
    if user.nil?
      # NOTE: could simplify this by expecting all taggable models to declare both public and user_id
      return false if taggable.respond_to?(:public) and !taggable.public
    elsif !user.superuser
      return false if taggable.respond_to?(:public) and !taggable.public and taggable.user_id != user.id
    end
    true
  end

end
