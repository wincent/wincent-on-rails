class Topic < ActiveRecord::Base
  belongs_to            :forum, counter_cache: true
  belongs_to            :user,  counter_cache: true
  belongs_to            :last_commenter,
                        class_name:  'User',
                        foreign_key: 'last_commenter_id'
  has_many              :comments,
                        -> { includes(:user).order('comments.created_at') },
                        as:        :commentable,
                        extend:    Commentable,
                        dependent: :destroy
  validates_presence_of :title
  validates_presence_of :body
  validates_length_of   :body, maximum: 128 * 1024
  attr_accessible       :title, :body, :public, :pending_tags, :accepts_comments
  before_create         :set_last_comment_info
  acts_as_classifiable
  acts_as_taggable
  set_callback          :create, :after, :send_new_topic_alert

  def send_new_topic_alert
    # don't inform admin of his own topics
    return if user && user.superuser?
    begin
      TopicMailer.new_topic_alert(self).deliver_now
    rescue Exception => e
      logger.error "\nerror: Topic#send_new_topic_alert for topic #{self.id} failed due to exception #{e.class}: #{e}\n\n"
    end
  end

  def self.find_topics_for_forum forum, offset = 0, limit = 20
    # we don't move this into the Forum model because if we did so we'd lose
    # the automatic mapping of int/string columns according to the topics schema.
    sql = <<-SQL
      SELECT topics.id, topics.title, topics.comments_count, topics.view_count,
             topics.updated_at, topics.last_comment_id,
             users.id AS last_active_user_id,
             users.display_name AS last_active_user_display_name
      FROM topics
      LEFT OUTER JOIN users ON (users.id = topics.last_commenter_id)
      WHERE topics.forum_id = ? AND public = TRUE AND awaiting_moderation = FALSE
      ORDER BY topics.updated_at DESC
      LIMIT ?, ?
    SQL
    find_by_sql [sql, forum.id, offset, limit]
  end

  def hit!
    Topic.increment_counter :view_count, id
  end

  def self.update_timestamps_for_comment_changes?
    true
  end

private

  def set_last_comment_info
    # part of fix for: https://wincent.com/issues/671
    # this allows us to drop the MySQL-specific conditional IFNULL logic from
    # the find_topics_for_forum method
    # - with the logic if the last commenter was anonymous we would end up
    #   showing the topic owner as the last commenter in the forums#show action
    # - without the logic we fix that problem but encounter another: now topics
    #   without replies no longer have "last post" info; the solution is to set
    #   things up here
    # - there is one more problem: if we delete all comments then we'll lose
    #   this information again so we also need to set it in the "after_destroy"
    #   callback in the Comment model
    self[:last_commenter_id] = user ? user.id : nil
    self[:last_commented_at] = Time.now
  end

end
