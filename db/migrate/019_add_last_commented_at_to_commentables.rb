class AddLastCommentedAtToCommentables < ActiveRecord::Migration
  def self.up
    # NOTE: as these columns are being added pre-deployment,
    # I'm not going to update the commentable tables here
    # (there are no comments yet)
    add_column :articles, :last_commented_at, :datetime
    add_column :issues, :last_commented_at, :datetime
    add_column :posts, :last_commented_at, :datetime
    add_column :topics, :last_commented_at, :datetime
  end

  def self.down
    remove_column :articles, :last_commented_at
    remove_column :issues, :last_commented_at
    remove_column :posts, :last_commented_at
    remove_column :topics, :last_commented_at
  end
end
