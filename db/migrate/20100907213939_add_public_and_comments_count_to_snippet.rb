class AddPublicAndCommentsCountToSnippet < ActiveRecord::Migration
  def self.up
    add_column :snippets, :public, :boolean, :default => true
    add_column :snippets, :comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :snippets, :comments_count
    remove_column :snippets, :public
  end
end
