class Comment < ActiveRecord::Base
  # can we use nested routes for polymorphic associations?
  belongs_to            :user
  belongs_to            :commentable, :polymorphic => true, :counter_cache => true
  validates_presence_of :body
  validates_presence_of :commentable
  acts_as_taggable
  attr_accessible       :body, :commentable

  def self.find_recent options = {}
    base_options = {:conditions => {'public' => true}, :order => 'created_at DESC', :limit => 10}
    find(:all, base_options.merge(options))
  end
end
