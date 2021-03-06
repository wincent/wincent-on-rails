class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.integer     :kind,                :default => 0,      :null => false
      t.string      :summary,             :null => false
      t.boolean     :public,              :default => true,   :null => false  # overridden depending on kind
      t.integer     :user_id,             :default => 0       # issues may be created by anonymous users
      t.integer     :status,              :default => 0,      :null => false
      t.text        :description
      t.boolean     :awaiting_moderation, :default => true,   :null => false
      t.boolean     :spam,                :default => false,  :null => false
      t.integer     :comments_count,      :default => 0,      :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
