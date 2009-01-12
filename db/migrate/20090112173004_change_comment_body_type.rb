class ChangeCommentBodyType < ActiveRecord::Migration
  def self.up
    change_column :comments, :body, :text, :limit => 16777215
  end

  def self.down
  end
end
