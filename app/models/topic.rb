class Topic < ActiveRecord::Base
  belongs_to  :forum,     :counter_cache => true
  belongs_to  :user
  belongs_to  :last_commenter, :class_name => 'User'
  has_many    :comments,  :as => :commentable, :extend => Commentable, :order => 'comments.created_at DESC',
              :dependent => :delete_all

  acts_as_taggable

  def hit!
    Topic.increment_counter :view_count, id
  end

end
