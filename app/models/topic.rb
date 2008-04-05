class Topic < ActiveRecord::Base
  belongs_to            :forum, :counter_cache => true
  belongs_to            :user
  belongs_to            :last_commenter, :class_name => 'User', :foreign_key => 'last_commenter_id'
  has_many              :comments,
                        :as         => :commentable,
                        :extend     => Commentable,
                        :order      => 'comments.created_at',
                        :dependent  => :destroy
  validates_presence_of :title
  validates_presence_of :body
  attr_accessible       :title, :body
  acts_as_taggable

  def self.find_topics_for_forum forum, offset = 0, limit = 20
    # TODO: consider moving this into the Forum model as Forum#find_topics or similar
    sql = <<-SQL
      SELECT topics.id, topics.title, topics.comments_count, topics.view_count, topics.updated_at, topics.last_comment_id,
             users.id AS last_active_user_id,
             users.display_name AS last_active_user_display_name
      FROM topics
      LEFT OUTER JOIN users ON (users.id = IFNULL(topics.last_commenter_id, topics.user_id))
      WHERE topics.forum_id = ? AND public = TRUE AND awaiting_moderation = FALSE AND spam = FALSE
      ORDER BY topics.updated_at DESC
      LIMIT ?, ?
    SQL
    find_by_sql [sql, forum.id, offset, limit]
  end

  def visible_comments
    # can't use the Commentable association mixin methods here becuse we need to specify an :include clause
    conditions = { :public => true, :awaiting_moderation => false, :spam => false, :commentable_id => self.id,
      :commentable_type => 'Topic' }
    Comment.find :all, :conditions => conditions, :include => 'user', :order => 'comments.created_at'
  end

  def hit!
    Topic.increment_counter :view_count, id
  end

  def self.update_timestamps_for_comment_changes?
    true
  end

  # NOTE: the moderate_as_spam!, moderate_as_ham! and moderate! methods are repeated in the comment model as well
  # may be worth refactoring to remove the duplication (either via a mix-in or an abstract superclass)
  def moderate_as_spam!
    moderate! true
  end

  def moderate_as_ham!
    moderate! false
  end

protected

  def moderate! is_spam
    # we don't want moderating a topic to mark it as updated, so use update_all
    self.awaiting_moderation  = false
    self.spam                 = is_spam
    Topic.update_all ['awaiting_moderation = FALSE, spam = ?', is_spam], ['id = ?', self.id]
  end
end
