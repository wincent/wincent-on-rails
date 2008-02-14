class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.integer     :type
      t.string      :summary,             :null => false
      t.integer     :status_id,           :null => false
      t.boolean     :public
      t.integer     :user_id              # issues may be created by anonymous users
      t.text        :description
      t.boolean     :awaiting_moderation, :default => true
      t.boolean     :spam,                :default => false
      t.integer     :comments_count,      :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
