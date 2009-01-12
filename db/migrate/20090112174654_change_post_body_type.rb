class ChangePostBodyType < ActiveRecord::Migration
  def self.up
    change_column :posts, :body, :text, :limit => 16777215
  end

  def self.down
  end
end
