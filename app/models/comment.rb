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
    # will also probably hit the updated_at column at this point too
    commentable.class.update_all ['comments_count = comments_count + 1, last_commenter_id = ?', user], ['id = ?', commentable.id]
  end

  def update_caches_after_destroy
    last_comment = commentable.comments.find(:first, :order => 'created_at DESC')
    user = last_comment ? last_comment.user : nil
    commentable.class.update_all ['comments_count = comments_count - 1, last_commenter_id = ?', user], ['id = ?', commentable.id]
  end
end
