class Comment < ActiveRecord::Base
  belongs_to            :user                               # no counter cache: see notes below
  belongs_to            :commentable, :polymorphic => true  # no counter cache: see notes below
  validates_presence_of :body
  validates_length_of   :body, :maximum => 128 * 1024
  validates_presence_of :commentable
  attr_accessible       :body
  acts_as_classifiable
  acts_as_taggable

  # NOTE: by defining an after_create action we break the built-in
  # counter-cache, so we must roll our own this isn't such a bad thing as we
  # want to do something more complex than just increment the counter anyway if
  # we wanted to avoid clobbering the Rails-generated counter cache callback we
  # could use alias_method_chain
  set_callback :create, :after, :update_caches_after_create
  set_callback :create, :after, :send_new_comment_alert
  set_callback :update, :after, :update_caches
  set_callback :destroy, :after, :update_caches

  scope :recent, where(:public => true).limit(10).order('created_at DESC')

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

  def update_caches
    conditions = {
      :awaiting_moderation => false, :commentable_id => commentable_id, :commentable_type => commentable_type
      }
    comment_count   = Comment.count :conditions => conditions
    last_comment    = Comment.last :conditions => conditions, :order => 'created_at'
    last_user       = last_comment ? last_comment.user : (commentable.user if commentable.respond_to?(:user))
    comment_id      = last_comment ? last_comment.id : nil
    last_commented  = last_comment ? last_comment.created_at : commentable.created_at
    updates         = 'comments_count = ?, last_commenter_id = ?, last_comment_id = ?, last_commented_at = ?, updated_at = ?'
    timestamp       = (update_timestamps_for_changes? && !last_commented.nil?) ? last_commented : commentable.updated_at
    commentable.class.update_all [updates, comment_count, last_user, comment_id, last_commented, timestamp],
      ['id = ?', commentable.id]

    if user
      user_comment_count = Comment.count :conditions => { :awaiting_moderation => false, :user_id => user.id }
      User.update_all ['comments_count = ?', user_comment_count], ['id = ?', user]
    end
  end

  def update_caches_after_create
    return if awaiting_moderation? # we defer update until moderation as ham has taken place

    # comment creation is a potentially common event so we want it to be fast, this is why we don't just call
    # the heavyweight update_caches method here (three SELECTs, one or two UPDATEs) and instead do the following
    # (one SELECT, one or two UPDATEs)
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

  def send_new_comment_alert
    # don't inform admin of his own comments
    return if self.user && self.user.superuser?
    begin
      CommentMailer.new_comment_alert(self).deliver
    rescue Exception => e
      # BUG: we're contaminating the code being tested here with knowledge
      # about the testing tools
      #   http://github.com/btakita/rr/issues/issue/40
      raise e if e.class.to_s =~ /RR::Errors/

      logger.error "\nerror: Comment#send_new_comment_alert for comment #{self.id} failed due to exception #{e.class}: #{e}\n\n"
    end
  end
end
