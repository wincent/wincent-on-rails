class AddLastCommenterToSnippets < ActiveRecord::Migration
  def self.up
    add_column :snippets, :last_commenter_id, :integer
    add_column :snippets, :last_comment_id, :integer
    add_column :snippets, :last_commented_at, :datetime
  end

  def self.down
    remove_column :snippets, :last_commented_at
    remove_column :snippets, :last_comment_id
    remove_column :snippets, :last_commenter_id
  end
end
