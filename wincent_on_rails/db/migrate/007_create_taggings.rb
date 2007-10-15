class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id,   :null => false  # polymorphic
      t.string  :taggable_type, :null => false  # polymorphic
      t.timestamps
    end
  end

  def self.down
    drop_table :taggings
  end
end
