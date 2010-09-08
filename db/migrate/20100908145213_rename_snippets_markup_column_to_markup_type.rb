class RenameSnippetsMarkupColumnToMarkupType < ActiveRecord::Migration
  def self.up
    rename_column :snippets, :markup, :markup_type
  end

  def self.down
    rename_column :snippets, :markup_type, :markup
  end
end
