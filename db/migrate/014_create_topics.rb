class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string      :title,               :null => false
      t.text        :body,                :null => false
      t.integer     :forum_id,            :null => false
      t.integer     :user_id,             :null => true     # topics can be anonymous
      t.boolean     :public,              :default => true, :null => false
      t.boolean     :accepts_comments,    :default => true, :null => false
      t.boolean     :awaiting_moderation, :default => true, :null => false
      t.integer     :comments_count,      :default => 0
      t.integer     :view_count,          :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
