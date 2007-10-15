class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string      :login_name,      :null => false
      t.string      :display_name,    :null => false
      t.string      :passphrase_hash, :null => false
      t.string      :passphrase_salt, :null => false
      t.integer     :locale_id
      t.boolean     :superuser,     :default => false
      t.boolean     :verified,      :default => false

      # can suspend (ban) users who abuse the system (for example, spammers)
      t.boolean     :suspended,     :default => false

      t.string      :session_key
      t.datetime    :session_expiry

      # never actually delete accounts from the db, but can mark them as deleted
      t.datetime    :deleted_at
      t.timestamps
    end

    # create new account with a psuedo-random passphrase (check the log to find out the passphrase)
    passphrase = User.passphrase
    u = User.create :login_name => 'admin', :display_name  => 'Administrator',
                    :passphrase => passphrase, :passphrase_confirmation => passphrase
    RAILS_DEFAULT_LOGGER.info "Created user #{u.login_name} with passphrase #{passphrase}"

  end

  def self.down
    drop_table :users
  end
end
