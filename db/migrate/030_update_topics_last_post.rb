class UpdateTopicsLastPost < ActiveRecord::Migration
  def self.up
    Topic.find(:all, :conditions => { :comments_count => 0 }).each do |topic|
      # must use update_all here to prevent Rails automatic timestamp updating from kicking in
      user = topic.user ? topic.user : nil
      Topic.update_all ['last_commenter_id = ?, last_commented_at = ?', user, topic.created_at], ['id = ?', topic.id]
    end
  end

  def self.down
  end
end
