class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string  :digest,                                :null => false
      t.string  :path,                                  :null => false
      t.string  :mime_type,                             :null => false
      t.integer :user_id,                               :null => true
      t.string  :original_filename,                     :null => false
      t.integer :filesize,                              :null => false
      t.integer :attachable_id,                         :null => true
      t.string  :attachable_type,                       :null => true
      t.boolean :awaiting_moderation, :default => true, :null => false
      t.boolean :public,              :default => true, :null => false
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of
    # is vulnerable to races)
    add_index :attachments, :digest, :unique => true
  end

  def self.down
    drop_table :attachments
  end
end
