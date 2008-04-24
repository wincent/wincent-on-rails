class Topic < ActiveRecord::Base
  belongs_to            :forum, :counter_cache => true
  belongs_to            :user, :counter_cache => true
  belongs_to            :last_commenter, :class_name => 'User', :foreign_key => 'last_commenter_id'
  has_many              :comments,
                        :as         => :commentable,
                        :extend     => Commentable,
                        :order      => 'comments.created_at',
                        :dependent  => :destroy
  validates_presence_of :title
  validates_presence_of :body
  attr_accessible       :title, :body
  acts_as_searchable    :attributes => [:title, :body]
  acts_as_taggable

  include Classifiable

  # we use alias_method_chain here because if we just declare an after_create callback
  # we'll clobber the method that Rails set up for us when we specified :counter_cache above
  def after_create_with_send_new_topic_alert
    after_create_without_send_new_topic_alert # let Rails update the counter cache
    begin
      return if self.user && self.user.superuser? # don't inform admin of his own comments
      TopicMailer.deliver_new_topic_alert self
    rescue Exception => e
      logger.error \
        "\nerror: Topic#after_create_with_send_new_topic_alert for topic #{self.id} failed due to exception #{e.class}: #{e}\n\n"
    end
  end
  alias_method_chain :after_create, :send_new_topic_alert

  def before_create
    # part of fix for: http://rails.wincent.com/issues/671
    # this allows us to drop the MySQL-specific conditional IFNULL logic from the find_topics_for_forum method
    # - with the logic if the last commenter was anonymous we would end up showing the topic owner as the last commenter
    #   in the forums#show action
    # - without the logic we fix that problem but encounter another: now topics without replies no longer have "last post"
    #   info; the solution is to set things up here
    # - there is one more problem: if we delete all comments then we'll lose this information again
    #   so we also need to set it in the "after_destroy" callback in the Comment model
    self[:last_commenter_id] = user ? user.id : nil
    self[:last_commented_at] = Time.now
  end

  def self.find_topics_for_forum forum, offset = 0, limit = 20
    # we don't move this into the Forum model because if we did so we'd lose the automatic mapping of int/string columns
    # according the topics schema.
    sql = <<-SQL
      SELECT topics.id, topics.title, topics.comments_count, topics.view_count, topics.updated_at, topics.last_comment_id,
             users.id AS last_active_user_id,
             users.display_name AS last_active_user_display_name
      FROM topics
      LEFT OUTER JOIN users ON (users.id = topics.last_commenter_id)
      WHERE topics.forum_id = ? AND public = TRUE AND awaiting_moderation = FALSE AND spam = FALSE
      ORDER BY topics.updated_at DESC
      LIMIT ?, ?
    SQL
    find_by_sql [sql, forum.id, offset, limit]
  end

  def visible_comments
    # can't use the Commentable association mixin methods here because we need to specify an :include clause
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
end
