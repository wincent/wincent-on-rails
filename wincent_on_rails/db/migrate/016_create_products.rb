class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :name, :null => false
      t.timestamps
    end

     # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
     add_index  :products, :name, :unique => true
  end

  def self.down
    drop_table :products
  end
end
