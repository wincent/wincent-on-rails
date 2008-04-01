class Topic < ActiveRecord::Base
  belongs_to  :forum,     :counter_cache => true
  belongs_to  :user
  belongs_to  :last_commenter, :class_name => 'User', :foreign_key => 'last_commenter_id'
  has_many    :comments,  :as => :commentable, :extend => Commentable, :order => 'comments.updated_at DESC', :dependent => :destroy
  acts_as_taggable

  # TODO: attr_accessible here to prevent taking over posts
  # current have some params that I want only the admin to be able to set
  # like "public" and "accepts comments"

  def self.find_topics_for_forum forum, offset, limit
    # option 1: full "N + 1" SELECT problem caused when the view does topic.last_commenter.display_name on each topic:
    #   forum.topics.find :all, :conditions => { :public => true, :awaiting_moderation => false },
    #     :limit => limit, :offset => offset
    #
    # option 2: "N + some": still incurring a topic.user.display_name query for each topic which doesn't have comments yet:
    #   forum.topics.find :all, :conditions => { :public => true, :awaiting_moderation => false },
    #     :limit => limit, :offset => offset, :include => 'last_commenter'
    #
    # option 3: "N + none": no extra queries, but two LEFT OUTER JOINS which make for a complex query:
    #   forum.topics.find :all, :conditions => { :public => true, :awaiting_moderation => false },
    #     :limit => limit, :offset => offset, :include => ['user', 'last_commenter']
    #
    # option 4: custom SQL, one LEFT OUTER JOIN and only pulls in only the columns required:
    sql = <<-SQL
      SELECT topics.id, topics.title, topics.comments_count, topics.view_count, topics.updated_at, topics.last_comment_id,
             users.id AS last_active_user_id,
             users.display_name AS last_active_user_display_name
      FROM topics
      LEFT OUTER JOIN users ON (users.id = IFNULL(topics.last_commenter_id, topics.user_id))
      WHERE topics.forum_id = ? AND public = TRUE AND awaiting_moderation = FALSE
      ORDER BY topics.updated_at DESC
      LIMIT ?, ?
    SQL
    find_by_sql [sql, forum.id, offset, limit]
  end

  def hit!
    Topic.increment_counter :view_count, id
  end

  def update_timestamps_for_comment_changes?
    true
  end
end
