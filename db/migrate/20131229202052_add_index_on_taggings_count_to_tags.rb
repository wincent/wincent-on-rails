class AddIndexOnTaggingsCountToTags < ActiveRecord::Migration
  def change
    add_index :tags, [:taggings_count, :name]
  end
end
