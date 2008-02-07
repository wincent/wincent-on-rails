class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string      :uri,         :null => false
      t.string      :permalink
      t.integer     :click_count, :default => 0
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index     :links, :uri,       :unique => true
    add_index     :links, :permalink, :unique => true
  end

  def self.down
    drop_table :links
  end
end
