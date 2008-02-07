class Comment < ActiveRecord::Base
  # can we use nested routes for polymorphic associations?
  belongs_to            :user
  belongs_to            :commentable, :polymorphic => true
  validates_presence_of :body
  acts_as_taggable
end
