class Comment < ActiveRecord::Base
  belongs_to            :user
  belongs_to            :commentable, :polymorphic => true
  has_many              :taggings,    :as => :taggable
  has_many              :tags,        :through => :taggings
  validates_presence_of :body
end
