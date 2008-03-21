class Comment < ActiveRecord::Base
  # can we use nested routes for polymorphic associations?
  belongs_to            :user
  belongs_to            :commentable, :polymorphic => true # no counter cache: see notes below
  validates_presence_of :body
  validates_presence_of :commentable
  acts_as_taggable
  attr_accessible       :body, :commentable

  # NOTE: by defining an after_create action we break the built-in counter-cache, so we must roll our own
  after_create          :update_caches_after_create
  after_destroy         :update_caches_after_destroy

  def self.find_recent options = {}
    base_options = {:conditions => {'public' => true}, :order => 'created_at DESC', :limit => 10}
    find(:all, base_options.merge(options))
  end

protected

  def update_caches_after_create
    updates = <<-UPDATES
      comments_count = comments_count + 1,
      last_commenter_id = ?,
      last_comment_id = ?,
      last_commented_at = ?
    UPDATES
    commentable.class.update_all [updates, user, id, created_at], ['id = ?', commentable.id]
  end

  def update_caches_after_destroy
    if last_comment = commentable.comments.find(:first, :order => 'created_at DESC')
      user        = last_comment.user
      comment_id  = last_comment.id
      timestamp   = last_comment.created_at
    else
      user        = nil
      comment_id  = nil
      timestamp   = commentable.created_at
    end
    updates = <<-UPDATES
      comments_count = comments_count - 1,
      last_commenter_id = ?,
      last_comment_id = ?,
      last_commented_at = ?
    UPDATES
    commentable.class.update_all [updates, user, comment_id, timestamp], ['id = ?', commentable.id]
  end
end
