class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text        :body,                :null => false
      t.integer     :user_id,             :null => false
      t.integer     :commentable_id,      :null => false  # polymorphic
      t.string      :commentable_type,    :null => false  # polymorphic
      t.boolean     :awaiting_moderation, :default => true
      t.boolean     :spam,                :default => false
      # TODO: I need a public field here too, so I can hide individual comments (useful in the issue tracker, for example)
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
