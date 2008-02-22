class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string      :name,          :null => false
      t.string      :description
      t.integer     :topics_count,  :default => 0
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index       :forums, :name, :unique => true
  end

  def self.down
    remove_index    :forums, :column => :name
    drop_table      :forums
  end
end
