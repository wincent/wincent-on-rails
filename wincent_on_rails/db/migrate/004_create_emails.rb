class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.integer     :user_id,             :null => false
      t.string      :address,             :null => false
      t.boolean     :verified,            :null => false, :default => false
      t.string      :verification_key
      t.datetime    :verification_limit
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index     :emails, :address, :unique => true
  end

  def self.down
    remove_index  :emails, :column => :address
    drop_table    :emails
  end
end
