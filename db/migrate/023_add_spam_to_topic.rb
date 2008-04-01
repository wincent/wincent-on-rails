class AddSpamToTopic < ActiveRecord::Migration
  class Topic < ActiveRecord::Base; end
  def self.up
    add_column :topics, :spam, :boolean, :null => false, :default => false
    Topic.update_all 'spam = FALSE'
  end

  def self.down
    remove_column :topics, :spam
  end
end
