class Comment < ActiveRecord::Base
  # can we use nested routes for polymorphic associations?
  belongs_to            :user
  belongs_to            :commentable, :polymorphic => true, :counter_cache => true
  validates_presence_of :user
  validates_presence_of :body
  validates_presence_of :commentable
  acts_as_taggable
  attr_accessible       :body, :commentable
end
