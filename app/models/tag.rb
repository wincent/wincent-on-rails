class Tag < ActiveRecord::Base
  has_many                :taggings
  has_many                :taggables, :through => :taggings
  validates_presence_of   :name
  validates_format_of     :name,
    :with => /\A[a-z0-9]+(\.[a-z0-9]+)*\z/i,
    :message => 'may only contain words (letters and numbers) separated by ' +
      'periods'
  validates_uniqueness_of :name
  attr_accessible         :name

  # returns a floating point number between 0 and 1 to denote a tag's relative popularity
  def normalized_taggings_count
    max = Tag.maximum :taggings_count  # the Rails query cache will cache this
    min = Tag.minimum :taggings_count  # the Rails query cache will cache this
    range = max - min
    count = self.taggings_count
    (count - min).to_f / range
  end

  # normalize tag names to lowercase
  def name= string
    super(string ? string.downcase : string)
  end

  def to_param
    name
  end

  # Given tag_names "foo", "bar" etc, find all items tagged with those
  # tags and identify what other tags could be used to narrow the search.
  def self.tags_reachable_from_tag_names *tag_names
    count = tag_names.length
    return [] if count < 1 or count > 5 # sanity limit: no more than 5 joins
    raise ArgumentError if tag_names.include?(nil)
    query = Array.new(count, 'name = ?').join ' OR '
    tags = where(query, *tag_names)
    tags_reachable_from_tags *tags
  end

  # Given actual tag objects, find all items tagged with those tags and
  # identify what other tags could be used to narrow the search.
  def self.tags_reachable_from_tags *tags
    # Goal here is to produce a query string that looks like this
    # (when "one-level deep", ie. looking at "foo"):
    #
    #   SELECT t2.tag_id AS id, tags.name, tags.taggings_count
    #   FROM tags, taggings AS t1
    #   JOIN taggings AS t2
    #   WHERE t1.tag_id = 38
    #   AND t2.taggable_id = t1.taggable_id
    #   AND t2.taggable_type = t1.taggable_type
    #   AND tags.id = t2.tag_id
    #   AND t2.tag_id NOT IN (38)
    #   GROUP BY t2.tag_id;
    #
    # Here is a sample when goal is "two levels deep"
    # (ie. looking at "foo bar"):
    #
    #   SELECT t3.tag_id AS id, tags.name, tags.taggings_count
    #   FROM tags, taggings AS t1
    #   JOIN taggings AS t2
    #   JOIN taggings AS t3
    #   WHERE t1.tag_id = 38
    #   AND t2.tag_id = 40
    #   AND t2.taggable_id = t1.taggable_id
    #   AND t2.taggable_type = t1.taggable_type
    #   AND t3.taggable_id = t1.taggable_id
    #   AND t3.taggable_type = t1.taggable_type
    #   AND tags.id = t3.tag_id
    #   AND t3.tag_id NOT IN (38, 40)
    #   GROUP BY t3.tag_id;
    tags = tags.flatten
    count = tags.length
    return [] if count < 1 or count > 5 # sanity limit: no more than 5 joins
    tag_ids = tags.collect(&:id)        # will raise if any tag is nil
    query = ["SELECT t#{count + 1}.tag_id AS id, tags.name, tags.taggings_count"]
    joins = ['taggings AS t1']
    ands  = []
    count.times do |i|
      joins << "taggings AS t#{i + 2}"
      ands.unshift "t#{count - i}.tag_id = #{tag_ids[count - i - 1]}"
      ands  << "t#{i + 2}.taggable_id = t1.taggable_id"
      ands  << "t#{i + 2}.taggable_type = t1.taggable_type"
    end
    ands << "tags.id = t#{count + 1}.tag_id"
    ands << "t#{count + 1}.tag_id NOT IN (" + tag_ids.join(', ') + ')'
    query << "FROM tags, " + joins.join(' JOIN ')
    query << "WHERE " + ands.join(' AND ')
    query << "GROUP BY t#{count + 1}.tag_id"
    query = query.join ' '
    Tag.find_by_sql query
  end
end
