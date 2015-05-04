class CreateTagMappings < ActiveRecord::Migration
  def change
    create_table :tag_mappings do |t|
      t.string :tag_name, null: false
      t.string :canonical_tag_name, null: false
      t.timestamps
    end

    add_index :tag_mappings, [:tag_name, :canonical_tag_name], unique: true
  end
end
