class AddPositionCategoryToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :position, :integer
    add_column :products, :category, :string
  end

  def self.down
    remove_column :products, :category
    remove_column :products, :position
  end
end
