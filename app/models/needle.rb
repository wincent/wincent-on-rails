# Full text search is like finding a needle in a hay stack.
class Needle < ActiveRecord::Base

  def self.tokenize string
    @@wikitext_parser ||= Wikitext::Parser.new
    @@wikitext_parser.fulltext_tokenize string
  end

  # Will return an array of Needle objects. Example:
  #   [#<Needle model_class: "Post", model_id: 13>]
  #
  # To actual get any useful information out of this array requires an additional database query
  # per result, so it could get quite expensive.
  #
  # Options:
  #   <tt>:user</tt>:: a user model object (if admin finds all records, if nil finds only public records, otherwise finds
  #                    records visible to that user)
  #   <tt>:type</tt>:: either <tt>:or</tt> (the default) to find models which feature any of the words in the query string, or
  #                    <tt>:and</tt> to find models which feature all of the words in the query string.
  def self.find_using_query_string query, options = {}
    sql = NeedleQuery.new(query, options).sql
    sql ? Needle.find_by_sql(sql) : []
  end

  class NeedleQuery
    AND_QUERY_LIMIT = 5   # AND queries are slow and heavy because they require multiple joins
    OR_QUERY_LIMIT  = 10  # OR queries are much faster, so allow up to ten components
    attr_reader :clauses

    def initialize query, options = {}
      defaults  = { :type => :or, :user => nil }
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
      @clauses[0..AND_QUERY_LIMIT].each do |clause|
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
      sql << " #{self.group_by} #{self.order_by}"
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
      sql << @clauses[0..OR_QUERY_LIMIT].join(" OR ")
      sql << ")"
      sql << " AND #{self.user_constraint}" unless self.user_constraint.blank?
      sql << " #{self.group_by} #{self.order_by}"
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
