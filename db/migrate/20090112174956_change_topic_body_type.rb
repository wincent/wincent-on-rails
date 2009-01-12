class ChangeTopicBodyType < ActiveRecord::Migration
  def self.up
    change_column :topics, :body, :text, :limit => 16777215
  end

  def self.down
  end
end
