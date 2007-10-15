class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string      :title
      t.string      :redirect # can redirect with a URLs (http://example.com/) or a wiki link ([[example]])
      t.boolean     :public
      t.boolean     :accepts_comments
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
