class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string      :display_name,        :null => false
      t.string      :passphrase_hash,     :null => false
      t.string      :passphrase_salt,     :null => false
      t.boolean     :superuser,           :default => false,  :null => false
      t.boolean     :verified,            :default => false,  :null => false

      # can suspend (ban) users who abuse the system (for example, spammers)
      t.boolean     :suspended,           :default => false,  :null => false

      t.string      :session_key
      t.datetime    :session_expiry

      # never actually delete accounts from the db, but can mark them as deleted
      t.datetime    :deleted_at,          :null => true
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index     :users, :display_name,  :unique => true
  end

  def self.down
    remove_index  :users, :column => :login_name
    remove_index  :users, :column => :display_name
    drop_table    :users
  end
end
