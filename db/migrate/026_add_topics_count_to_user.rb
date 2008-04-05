class AddTopicsCountToUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_many :topics
  end

  def self.up
    add_column :users, :topics_count, :integer, :default => 0
    User.find(:all).each do |u|
      User.update_all ['topics_count = ?', u.topics.count], ['id = ?', u.id]
    end
  end

  def self.down
    remove_column :users, :topics_count
  end
end
