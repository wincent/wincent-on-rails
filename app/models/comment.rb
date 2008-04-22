class Comment < ActiveRecord::Base
  belongs_to            :user                               # no counter cache: see notes below
  belongs_to            :commentable, :polymorphic => true  # no counter cache: see notes below
  validates_presence_of :body
  validates_presence_of :commentable
  attr_accessible       :body
  acts_as_taggable

  # NOTE: by defining an after_create action we break the built-in counter-cache, so we must roll our own
  # this isn't such a bad thing as we want to do something more complex than just increment the counter anyway
  # if we wanted to avoid clobbering the Rails-generated counter cache callback we could use alias_method_chain
  after_create          :update_caches_after_create, :send_new_comment_alert
  after_destroy         :update_caches_after_destroy

  include Classifiable

  def self.find_recent options = {}
    base_options = { :conditions => { :public => true }, :order => 'created_at DESC', :limit => 10 }
    find :all, base_options.merge(options)
  end

protected

  # By implementing the optional update_timestamps_for_comment_changes?
  # method commentable classes can control whether their timestamps get
  # updated whenever new comments are created or destroyed.
  #
  # For example, an Issue or a (forum) Topic should be considered
  # "updated" whenever a new comment is added, but a Post or Article
  # should not.
  def update_timestamps_for_changes?
    klass = commentable.class
    if klass.respond_to? :update_timestamps_for_comment_changes?
      klass.update_timestamps_for_comment_changes?
    else
      false
    end
  end

  # NOTE: possible bug here: when a comment is queued for moderation the commentable will get updated
  # if the comment is later marked as spam then we will have updated the commentable for nothing
  # therefore may need to consider adding yet another callback to handle this kind of case (an after save callback)
  def update_caches_after_create
    updates = <<-UPDATES
      comments_count    = comments_count + 1,
      last_commenter_id = ?,
      last_comment_id   = ?,
      last_commented_at = ?,
      updated_at        = ?
    UPDATES
    timestamp = update_timestamps_for_changes? ? created_at : commentable.updated_at
    commentable.class.update_all [updates, user, id, created_at, timestamp], ['id = ?', commentable.id]
    User.update_all ['comments_count = comments_count + 1'], ['id = ?', user] if user
  end

  def update_caches_after_destroy
    last_comment    = commentable.comments.find(:first, :order => 'comments.created_at DESC')
    last_user       = last_comment ? last_comment.user : (commentable.user if commentable.respond_to?(:user))
    comment_id      = last_comment ? last_comment.id : nil
    last_commented  = last_comment ? last_comment.created_at : commentable.created_at
    updates = <<-UPDATES
      comments_count    = comments_count - 1,
      last_commenter_id = ?,
      last_comment_id   = ?,
      last_commented_at = ?,
      updated_at        = ?
    UPDATES
    timestamp = (update_timestamps_for_changes? && !last_commented.nil?) ? last_commented : commentable.created_at
    commentable.class.update_all [updates, last_user, comment_id, last_commented, timestamp], ['id = ?', commentable.id]
    User.update_all ['comments_count = comments_count - 1'], ['id = ?', user] if user
  end

  def send_new_comment_alert
    begin
      return if self.user && self.user.superuser? # don't inform admin of his own comments
      CommentMailer.deliver_new_comment_alert self
    rescue Exception => e
      logger.error "\nerror: Comment#send_new_comment_alert for comment #{self.id} failed due to exception #{e.class}: #{e}\n\n"
    end
  end
end
