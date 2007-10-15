class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id,   :null => false  # polymorphic
      t.string  :taggable_type, :null => false  # polymorphic
      t.timestamps
    end

    # don't allow  the same tag to be applied twice to the same target
    add_index     :taggings, [:tag_id, :taggable_id, :taggable_type], :unique => true
  end

  def self.down
    remove_index  :taggings, :column => [:tag_id, :taggable_id, :taggable_type]
    drop_table :taggings
  end
end
