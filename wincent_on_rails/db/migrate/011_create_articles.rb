class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string      :title,             :null => false
      t.string      :redirect           # can redirect with a URLs (http://example.com/) or a wiki link ([[example]])
      t.text        :body,              :null => false
      t.boolean     :public,            :default => true, :null => false
      t.boolean     :accepts_comments,  :default => false, :null => false
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index     :articles, :title, :unique => true
  end

  def self.down
    remove_index  :articles, :column => :title
    drop_table    :articles
  end
end
