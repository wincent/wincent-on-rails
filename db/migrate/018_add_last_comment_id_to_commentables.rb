class AddLastCommentIdToCommentables < ActiveRecord::Migration
  def self.up
    # NOTE: as these columns are being added pre-deployment,
    # I'm not going to update the commentable tables here
    # (there are no comments yet)
    add_column :articles, :last_comment_id, :integer
    add_column :issues, :last_comment_id, :integer
    add_column :posts, :last_comment_id, :integer
    add_column :topics, :last_comment_id, :integer
  end

  def self.down
    remove_column :articles, :last_comment_id
    remove_column :issues, :last_comment_id
    remove_column :posts, :last_comment_id
    remove_column :topics, :last_comment_id
  end
end
