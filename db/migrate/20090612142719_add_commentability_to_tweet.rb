class AddCommentabilityToTweet < ActiveRecord::Migration
  def self.up
    add_column :tweets, :accepts_comments, :boolean, :default => false, :null => false
    add_column :tweets, :comments_count, :integer, :default => 0, :null => false
    add_column :tweets, :last_commenter_id, :integer
    add_column :tweets, :last_comment_id, :integer
    add_column :tweets, :last_commented_at, :datetime

    Tweet.update_all 'accepts_comments = FALSE'
    Tweet.update_all 'comments_count = 0'
  end

  def self.down
    remove_column :tweets, :accepts_comments
    remove_column :tweets, :comments_count
    remove_column :tweets, :last_commenter_id
    remove_column :tweets, :last_comment_id
    remove_column :tweets, :last_commented_at
  end
end
