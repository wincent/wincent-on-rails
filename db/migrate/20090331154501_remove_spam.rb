class RemoveSpam < ActiveRecord::Migration
  def self.up
    remove_column :comments, :spam
    remove_column :issues, :spam
    remove_column :topics, :spam
  end

  def self.down
    add_column :comments, :spam, :bool, :null => false, :default => false
    add_column :issues, :spam, :bool, :null => false, :default => false
    add_column :topics, :spam, :bool, :null => false, :default => false
    Comment.update_all 'spam = FALSE'
    Issue.update_all 'spam = FALSE'
    Topic.update_all 'spam = FALSE'
  end
end
