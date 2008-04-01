class Forum < ActiveRecord::Base
  has_many                :topics, :order => 'topics.updated_at DESC', :dependent => :destroy
  validates_presence_of   :name
  validates_format_of     :name, :with => /\A[a-z ]+\z/i, :message => 'may only contain letters and spaces'
  validates_uniqueness_of :name

  def self.find_with_param! param
    # forum name will be downcased in the URL, but MySQL will do a case-insensitive search for us anyway
    find_by_name(deparametrize(param)) || (raise ActiveRecord::RecordNotFound)
  end

  def self.find_all
    find_by_sql <<-SQL
      SELECT forums.id, forums.name, forums.description, forums.topics_count,
             outer_t.updated_at AS last_active_at, outer_t.id AS last_topic_id
      FROM forums
      JOIN (SELECT id, forum_id, updated_at
            FROM (SELECT id, forum_id, updated_at
                  FROM topics
                  ORDER BY forum_id, updated_at DESC)
                  AS inner_t GROUP BY forum_id)
            AS outer_t
      WHERE forums.id = outer_t.forum_id
      ORDER BY forums.position
    SQL
  end

  def self.deparametrize string
    string.gsub '-', ' '
  end

  def self.parametrize string
    string.downcase.gsub ' ', '-'
  end

  def to_param
    Forum.parametrize name
  end
end
