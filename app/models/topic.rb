class Topic < ActiveRecord::Base
  belongs_to  :forum,     :counter_cache => true
  belongs_to  :user
  belongs_to  :last_commenter, :class_name => 'User', :foreign_key => 'last_commenter_id'
  has_many    :comments,  :as => :commentable, :extend => Commentable, :order => 'comments.updated_at DESC',
              :dependent => :delete_all

  acts_as_taggable

  def hit!
    Topic.increment_counter :view_count, id
  end

  def update_timestamps_for_comment_changes?
    true
  end
end
