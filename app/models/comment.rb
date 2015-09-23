class Comment < ActiveRecord::Base
  belongs_to            :user                               # no counter cache: see notes below
  belongs_to            :commentable, :polymorphic => true  # no counter cache: see notes below
  validates_presence_of :body
  validates_length_of   :body, :maximum => 128 * 1024
  validates_presence_of :commentable

  attr_accessible       :body, :public

  acts_as_classifiable
  acts_as_taggable

  # NOTE: by defining an after_create action we break the built-in
  # counter-cache, so we must roll our own this isn't such a bad thing as we
  # want to do something more complex than just increment the counter anyway if
  # we wanted to avoid clobbering the Rails-generated counter cache callback we
  # could use alias_method_chain
  set_callback :create, :after, :update_caches_after_create
  set_callback :update, :after, :update_caches
  set_callback :destroy, :after, :update_caches

  scope :published, -> { where(public: true) }
  scope :recent,    -> { published.order('created_at DESC').limit(10) }

protected

  # By implementing the optional update_timestamps_for_comment_changes?
  # method commentable classes can control whether their timestamps get
  # updated whenever new comments are created or destroyed.
  #
  # For example, an Issue or should be considered "updated" whenever a new
  # comment is added, but a Post or Article should not.
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
    comment_count   = Comment.where(conditions).count
    last_comment    = Comment.where(conditions).order('created_at').last
    last_user       = last_comment ? last_comment.user : (commentable.user if commentable.respond_to?(:user))
    comment_id      = last_comment ? last_comment.id : nil
    last_commented  = last_comment ? last_comment.created_at : commentable.created_at
    updates         = 'comments_count = ?, last_commenter_id = ?, last_comment_id = ?, last_commented_at = ?, updated_at = ?'
    timestamp       = (update_timestamps_for_changes? && !last_commented.nil?) ? last_commented : commentable.updated_at
    commentable.class.where(id: commentable).update_all([updates, comment_count, last_user, comment_id, last_commented, timestamp])

    if user
      user_comment_count = Comment.where(awaiting_moderation: false, user_id: user).count
      user.update_column(:comments_count, user_comment_count)
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
    commentable.class.where(id: commentable).
      update_all([updates, user, id, created_at, timestamp])
    User.increment_counter(:comments_count, user.id) if user
  end
end
