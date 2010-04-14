class Forum < ActiveRecord::Base
  has_many                :topics,
                          :order => 'topics.updated_at DESC',
                          :dependent => :destroy
  validates_presence_of   :name
  validates_format_of     :name,
                          :with => /\A[a-z0-9\- ]+\z/i,
                          :message => 'may only contain letters, numbers, hyphens and spaces'
  validates_uniqueness_of :name
  validates_presence_of   :permalink
  validates_format_of     :permalink,
                          :with => /\A[a-z0-9\-]+\z/,
                          :message => 'must contain only lowercase letters, numbers and hyphens'
  validates_uniqueness_of :permalink
  attr_accessible         :name, :description, :permalink

  def self.find_with_param! param, conditions = {}
    # forum name will be downcased in the URL, but MySQL will do a
    # case-insensitive search for us anyway
    find_by_permalink! param, :conditions => conditions
  end

  def self.find_all
    find_by_sql <<-SQL
      SELECT forums.id, forums.name, forums.description, forums.topics_count,
             t.updated_at AS last_active_at, t.id AS last_topic_id
      FROM forums
      LEFT OUTER JOIN (SELECT id, forum_id, updated_at
            FROM topics
            WHERE awaiting_moderation = FALSE
            AND public = TRUE
            ORDER BY forum_id, updated_at DESC) AS t
      ON forums.id = t.forum_id
      WHERE forums.public = TRUE
      GROUP BY forums.id
      ORDER BY forums.position
    SQL
  end

  def before_create
    if self.position.nil?
      max = Forum.maximum(:position)
      self.position = max ? max + 1 : 0
    end
  end

  def before_validation
    if permalink.blank?
      # Given that collisions here are unlikely (unlike the Post model),
      # we just make a reasonable effort and rely on uniqueness
      # validations and database contraints to warn us of any clash.
      self.permalink = name.to_s.downcase.gsub ' ', '-'
    end
    true
  end

  def to_param
    permalink
  end
end
