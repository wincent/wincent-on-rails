class AddAcceptsCommentsToSnippets < ActiveRecord::Migration
  def self.up
    add_column :snippets, :accepts_comments, :boolean, :default => true
  end

  def self.down
    remove_column :snippets, :accepts_comments
  end
end
