class Topic < ActiveRecord::Base
  belongs_to  :forum,     :counter_cache => true
  belongs_to  :user
  belongs_to  :last_commenter, :class_name => 'User', :foreign_key => 'last_commenter_id'
  has_many    :comments,  :as => :commentable, :extend => Commentable, :order => 'comments.updated_at DESC', :dependent => :destroy
  acts_as_taggable

  # TODO: attr_accessible here to prevent taking over posts
  # current have some params that I want only the admin to be able to set
  # like "public" and "accepts comments"

  def hit!
    Topic.increment_counter :view_count, id
  end

  def update_timestamps_for_comment_changes?
    true
  end
end
