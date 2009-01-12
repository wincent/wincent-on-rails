class ChangeIssueDescriptionType < ActiveRecord::Migration
  def self.up
    change_column :issues, :description, :text, :limit => 16777215
  end

  def self.down
  end
end
