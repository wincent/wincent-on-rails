class RemoveIconExtensionFromProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :icon_extension
  end

  def self.down
    add_column :products, :icon_extension, :string
  end
end
