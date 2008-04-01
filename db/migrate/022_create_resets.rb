class CreateResets < ActiveRecord::Migration
  def self.up
    create_table :resets do |t|
      t.integer     :user_id,       :null => false
      t.string      :secret,        :null => false
      t.datetime    :cutoff,        :null => false  # reset must occur before the cut
      t.datetime    :completed_at,  :null => true   # will be null until completed
      t.timestamps
    end
  end

  def self.down
    drop_table :resets
  end
end
