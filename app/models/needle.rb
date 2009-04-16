# Full text search is like finding a needle in a hay stack.
#
# Table fields:
#
#   string  :model_class,     :default => '', :null => false
#   integer :model_id,                        :null => false
#   string  :attribute_name,  :default => '', :null => false
#   string  :content,         :default => '', :null => false
#   integer :user_id
#   boolean :public
#
# Note that for speed neither a real ActiveRecord "belongs_to" association
# nor timestamp fields (updated_at, created_at) are used.
class Needle < ActiveRecord::Base
  # internally generated from "safe" inputs, so basically everything is
  # accessible
  attr_accessible :model_class, :model_id, :attribute_name, :content, :user_id,
    :public

  def self.tokenize string
    @@wikitext_parser ||= Wikitext::Parser.new
    @@wikitext_parser.fulltext_tokenize string
  end

  # Options:
  #   <tt>:user</tt>:: a user model object (if admin finds all records, if nil finds only public records, otherwise finds
  #                    records visible to that user)
  #   <tt>:type</tt>:: either <tt>:or</tt> (the default) to find models which feature any of the words in the query string, or
  #                    <tt>:and</tt> to find models which feature all of the words in the query string.
  def self.find_using_query_string query, options = {}
    sql = NeedleQuery.new(query, options).sql
    prefetch_models(sql ? Needle.find_by_sql(sql) : [])
  end

private

  # Normally a Needle.find_by_sql query would return an array of Needle objects like this:
  #
  #   [#<Needle model_class: "Post", model_id: 13>]
  #
  # To actual get any useful information out of this array would requires an additional database query
  # per result, so it could get quite expensive (the typical "N + 1 SELECT" problem).
  #
  # Here we try to minimize the number of additional queries by "prefetching" the models in groups. Just say we had
  # 5 articles, 5 issues, 5 posts and 5 topics, we would get all 20 objects using 4 queries (1 per model type) and return
  # them in an array.
  #
  def self.prefetch_models models
    model_cache = Hash.new { |hash, key| hash[key] = {} }
    models.each { |model| model_cache[model.model_class][model.model_id] = nil }
    model_cache.each do |model_class, ids|
      results = model_class.constantize.find(:all, :conditions => ['id IN (?)', ids.keys]).each do |result|
        model_cache[model_class][result.id] = result
      end
      if ids.length > results.length
        self.logger.warn \
          "warning: expected #{ids.length} #{model_class} instance(s) but found only #{results.length} (search index out of date)"
      end
    end
    models.collect { |model| model_cache[model.model_class][model.model_id] }
  end

  class NeedleQuery
    AND_QUERY_LIMIT = 5   # AND queries are slow and heavy because they require multiple joins
    OR_QUERY_LIMIT  = 10  # OR queries are much faster, so allow up to ten components
    ROW_LIMIT       = 20  # will try to fetch twenty rows at a time
    attr_reader :clauses

    def initialize query, options = {}
      defaults  = { :type => :or, :user => nil, :offset => 0 }
      @query    = query
      @options  = defaults.merge(options)
      @columns  = 'model_class, model_id, COUNT(*) AS count'

      # preprocessing
      @ignored  = []  # TODO: report back ignored words (in errors?); these will get shown in the flash
      prepare_clauses
    end

    def sql
      clause_count = @clauses.length
      if clause_count == 0
        nil
      elsif clause_count == 1 or @options[:type] == :or
        sql_for_OR_query
      elsif @options[:type] == :and
        sql_for_AND_query
      else
        raise 'unrecognized type'
      end
    end

    # Given a query string like: "title:hello here there", and user with id 1, we want to produce a query like:
    #
    #   SELECT model_class, model_id, COUNT(*) AS count FROM needles
    #       JOIN (SELECT model_class, model_id FROM needles WHERE content = 'here') AS sub1
    #           USING (model_class, model_id)
    #       JOIN (SELECT model_class, model_id FROM needles WHERE content = 'are') AS sub2
    #           USING (model_class, model_id)
    #   WHERE attribute_name = 'title' AND content = 'hello'
    #   AND (user_id = 1 OR public = TRUE OR public IS NULL)
    #   GROUP BY model_class, model_id
    #   ORDER BY count DESC;
    #
    def sql_for_AND_query
      sql = self.base_query
      @columns = 'model_class, model_id'
      count = 1
      first = true
      pending = nil
      @clauses[0...AND_QUERY_LIMIT].each do |clause|
        if first
          pending = clause
          first = false
          next
        end
        sql << " JOIN (#{self.base_query} WHERE #{clause}) AS sub#{count} USING (model_class, model_id)"
        count += 1
      end
      sql << " WHERE #{pending}"
      sql << " AND #{self.user_constraint}" unless self.user_constraint.blank?
      sql << " #{self.group_by} #{self.order_by} #{self.limit}"
    end

    # Given a query string like: "title:hello here there", and user with id 1, we want to produce a query like:
    #
    #   SELECT model_class, model_id, COUNT(*) AS count
    #   FROM needles
    #   WHERE ((attribute_name = 'title' AND content = 'hello') -- first criterion
    #          OR (content = 'here')                            -- second criterion
    #          OR (content = 'there'))                          -- third criterion
    #   AND (user_id = 1 OR public = TRUE OR public IS NULL)    -- user constraint
    #   GROUP BY model_class, model_id
    #   ORDER BY count DESC;
    #
    # Which will yield a result like this:
    #
    #   +-------------+----------+-------+
    #   | model_class | model_id | count |
    #   +-------------+----------+-------+
    #   | article     |        1 |     3 |
    #   | article     |        3 |     2 |
    #   +-------------+----------+-------+
    #
    def sql_for_OR_query
      sql = "#{base_query} WHERE ("
      sql << @clauses[0...OR_QUERY_LIMIT].join(" OR ")
      sql << ")"
      sql << " AND #{self.user_constraint}" unless self.user_constraint.blank?
      sql << " #{self.group_by} #{self.order_by} #{self.limit}"
    end

    def base_query
      "SELECT #{@columns} FROM needles"
    end

    def group_by
      'GROUP BY model_class, model_id'
    end

    def order_by
      'ORDER BY count DESC'
    end

    def limit
      # we try to retrieve one more row than we actually intend to use
      # this is how we detect when to display a "more" link in the search results
      "LIMIT #{@options[:offset].to_i}, #{ROW_LIMIT + 1}"
    end

    def user_constraint
      if @options[:user].nil? # no user: public records only
        '(public = TRUE OR public IS NULL)'
      elsif @options[:user].superuser? # admin user: no constraint
        ''
      else # normal user: user's own records plus public records
        "(user_id = #{@options[:user].id} OR public = TRUE OR public IS NULL)"
      end
    end

    def tokenize_and_sanitize_clause attribute_name, content
      Needle.tokenize(content).collect do |token|
        conditions = { 'content' => token }
        conditions['attribute_name'] = attribute_name unless attribute_name.blank?
        Needle.send(:sanitize_sql_hash_for_conditions, conditions)
      end
    end

    def prepare_clauses
      @clauses = []
      @query.split(/\s+/).each do |clause|
        attribute_name, content = '', ''
        if index = clause.index(':')
          if index > 0
            attribute_name  = clause[0..index - 1]
            word = clause[index + 1..-1]
            unless word.blank? or attribute_name =~ /\A(https?|ftp|svn|mailto)\z/i
              @clauses.push *tokenize_and_sanitize_clause(attribute_name, word)
              next
            end
          end
        end
        @clauses.push *tokenize_and_sanitize_clause(nil, clause) # fallback case: no valid attribute supplied
      end
    end
  end # class NeedleQuery
end
