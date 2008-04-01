class AddPositionToForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :position, :integer, :null => true
  end

  def self.down
    remove_column :forums, :position
  end
end
