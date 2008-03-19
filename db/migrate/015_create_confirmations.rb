class CreateConfirmations < ActiveRecord::Migration
  def self.up
    create_table :confirmations do |t|
      t.integer     :email_id,      :null => false
      t.string      :secret,        :null => false
      t.datetime    :cutoff,        :null => false  # confirmation must occur before the cutoff date
      t.datetime    :completed_at,  :null => true   # will be null until completed
      t.timestamps
    end
  end

  def self.down
    drop_table :confirmations
  end
end
