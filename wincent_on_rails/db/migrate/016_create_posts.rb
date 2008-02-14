class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string      :title,             :null => false
      t.string      :permalink,         :null => false
      t.text        :excerpt,           :null => false
      t.text        :body
      t.boolean     :public,            :default => true, :null => false
      t.boolean     :accepts_comments,  :default => false, :null => false
      t.integer     :comments_count,    :default => 0
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index     :posts, :permalink, :unique => true
  end

  def self.down
    remove_index  :posts, :column => :permalimk
    drop_table    :posts
  end
end
