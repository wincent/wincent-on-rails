class UpdateTopicsLastPost < ActiveRecord::Migration
  def self.up
    Topic.find(:all, :conditions => { :comments_count => 0 }).each do |topic|
      topic.last_commenter    = topic.user
      topic.last_commented_at = topic.created_at
      topic.save
    end
  end

  def self.down
  end
end
