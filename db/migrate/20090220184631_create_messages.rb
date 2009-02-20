class CreateMessages < ActiveRecord::Migration
  def self.up
    # all fields (except "incoming" flag) are optional
    create_table :messages do |t|
      t.integer :related_id
      t.string  :related_type
      t.string  :message_id_header
      t.string  :to_header
      t.string  :from_header
      t.string  :subject_header
      t.string  :in_reply_to_header
      t.text    :body
      t.boolean :incoming, :default => true, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
