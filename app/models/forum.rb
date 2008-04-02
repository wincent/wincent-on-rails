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
             t.updated_at AS last_active_at, t.id AS last_topic_id
      FROM forums
      LEFT OUTER JOIN (SELECT id, forum_id, updated_at
            FROM topics
            ORDER BY forum_id, updated_at DESC) AS t
      ON forums.id = t.forum_id
      GROUP BY forums.id
      ORDER BY forums.position
    SQL
  end

  def self.deparametrize string
    string.gsub '-', ' '
  end

  def self.parametrize string
    string.downcase.gsub ' ', '-'
  end

  def after_create
    if self.position.nil?
      max = Forum.maximum(:position)
      self.position = max ? max + 1 : 0
    end
  end

  def to_param
    Forum.parametrize name
  end
end
