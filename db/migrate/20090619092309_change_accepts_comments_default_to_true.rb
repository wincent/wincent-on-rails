class ChangeAcceptsCommentsDefaultToTrue < ActiveRecord::Migration
  def self.up
    change_column :articles,  :accepts_comments, :boolean, :default => true, :null => false
    change_column :posts,     :accepts_comments, :boolean, :default => true, :null => false
    change_column :tweets,    :accepts_comments, :boolean, :default => true, :null => false
  end

  def self.down
    change_column :articles,  :accepts_comments, :boolean, :default => false, :null => false
    change_column :posts,     :accepts_comments, :boolean, :default => false, :null => false
    change_column :tweets,    :accepts_comments, :boolean, :default => false, :null => false
  end
end
