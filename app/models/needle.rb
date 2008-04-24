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
  #   <tt>:type</tt>:: either <tt>:or</tt> to find models which feature any of the words in the query string, or <tt>:and</tt>
  #                    (the default) to find models which feature all of the words in the query string.
  def self.find_using_query_string query, options = {}
    sql = NeedleQuery.new(query, options).sql
    sql ? Needle.find_by_sql(sql) : []
  end

  class NeedleQuery
    def initialize query, options = {}
      @query    = query
      @options  = options
      @columns  = 'model_class, model_id, COUNT(*) AS count'

      # preprocessing
      @ignored  = []  # TODO: report back ignored words (in errors?); these will get shown in the flash
      @words    = Needle.tokenize @query
      # BUG: this will break out "title:foo" because that will get tokenize as "title", "foo"
    end

    def sql
      case @words.length
      when 0
        nil
      when 1
        sql_for_simple_query_string @words[0]
      else
        if @options[:type] == :or
          sql_for_OR_query_string @words
        else
          sql_for_AND_query_string @words
        end
      end
    end

    # Given a query string that only contains a single word like: "title:hello"
    #
    #   SELECT model_class, model_id, COUNT(*) AS count FROM needles WHERE attribute_name = 'title' AND content = 'hello'
    #   AND (user_id = 1 OR user_id IS NULL)
    #   GROUP BY model_class, model_id
    #   ORDER BY count DESC;
    #
    # Note that we eliminate all subqueries in this case, and merge the user constraint into the only WHERE clause.
    #
    def sql_for_simple_query_string word
      sql = self.base_query
      sql << " WHERE #{self.clause_for_word(word)}"
      sql << " AND #{self.user_constraint}" unless self.user_constraint.blank?
      sql << " #{self.group_by}"
      sql << " #{self.order_by};"
    end

    # Given a query string like: "title:hello here there", and user with id 1, we want to produce a query like:
    #
    #   SELECT model_class, model_id, COUNT(*) AS count FROM needles
    #       JOIN (SELECT model_class, model_id FROM needles WHERE content = 'here') AS sub1
    #           USING (model_class, model_id)
    #       JOIN (SELECT model_class, model_id FROM needles WHERE content = 'are') AS sub2
    #           USING (model_class, model_id)
    #   WHERE attribute_name = 'title' AND content = 'hello'
    #   AND (user_id = 1 OR user_id IS NULL)
    #   GROUP BY model_class, model_id
    #   ORDER BY count DESC;
    #
    def sql_for_AND_query_string words
      sql = self.base_query
      @columns = 'model_class, model_id'
      count = 1
      first = true
      pending = nil
      words.each do |word|
        if first
          pending = self.clause_for_word word
          first = false
          next
        end
        clause = self.clause_for_word word
        sql << " JOIN (#{self.base_query} WHERE #{clause}) AS sub#{count} USING (model_class, model_id)"
        count += 1
      end
      sql << " WHERE #{pending}"
      sql << " AND #{self.user_constraint}" unless self.user_constraint.blank?
      sql << " #{self.group_by}"
      sql << " #{self.order_by};"
    end

    # Given a query string like: "title:hello here there", and user with id 1, we want to produce a query like:
    #
    #   SELECT model_class, model_id, COUNT(*) AS count FROM (
    #       (SELECT model_class, model_id, user_id FROM needles WHERE attribute_name = 'title' AND content = 'hello')
    #           UNION ALL
    #       (SELECT model_class, model_id, user_id FROM needles WHERE content = 'here')
    #           UNION ALL
    #       (SELECT model_class, model_id, user_id FROM needles WHERE content = 'there')
    #   ) AS temp
    #   WHERE (user_id = 1 OR user_id IS NULL)
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
    def sql_for_OR_query_string words
      sql = "SELECT #{@columns} FROM ("
      if self.user_constraint.blank?
        @columns = 'model_class, model_id'
      else
        @columns = 'model_class, model_id, user_id'
      end
      first = true
      words.each do |word|
        if first
          first = false
        else
          sql << ' UNION ALL'
        end
        sql << " (#{self.base_query} WHERE #{self.clause_for_word(word)})"
      end
      sql << ') AS temp'
      sql << " WHERE #{self.user_constraint}" unless self.user_constraint.blank?
      sql << " #{self.group_by}"
      sql << " #{self.order_by};"
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
      if @user_constraint.nil?
        if @options[:user].nil?           # no user: public records only
          @user_constraint = '(user_id IS NULL)'
        elsif @options[:user].superuser?  # admin user: no constraint
          @user_constraint = ''
        else                              # normal user: user's own records plus public records
          @user_constraint = "(user_id = #{@options[:user].id} OR user_id IS NULL)"
        end
      end
      @user_constraint
    end

    def clause_for_word word
      attribute_name, content = '', ''
      if index = word.index(':')
        if index > 1
          attribute_name  = word[0..index - 1]
          content         = word[index + 1..-1]
        end
      end
      if content.blank?
        attribute_name  = nil
        content         = word
      end
      conditions = { 'content' => content }
      conditions['attribute_name'] = attribute_name unless attribute_name.blank?
      Needle.send(:sanitize_sql_hash_for_conditions, conditions)
    end
  end # class NeedleQuery
end
