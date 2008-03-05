class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :name,          :null => false
      t.string      :permalink,     :null => false
      t.string      :icon_extension
      t.text        :description    # wikitext, appears on index page
      t.timestamps
    end

     # database-level constraints to ensure uniqueness (validates_uniqueness_of vulnerable to races)
     add_index  :products, :name,       :unique => true
     add_index  :products, :permalink,  :unique => true
  end

  def self.down
    remove_index  :products, :column => :permalink
    remove_index  :products, :column => :name
    drop_table    :products
  end
end
