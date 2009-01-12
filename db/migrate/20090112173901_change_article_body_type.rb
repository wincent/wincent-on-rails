class ChangeArticleBodyType < ActiveRecord::Migration
  def self.up
    change_column :articles, :body, :text, :limit => 16777215
  end

  def self.down
  end
end
