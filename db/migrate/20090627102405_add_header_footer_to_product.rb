class AddHeaderFooterToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :header, :text, null: false
    add_column :products, :footer, :text, null: false
  end

  def self.down
    remove_column :products, :footer
    remove_column :products, :header
  end
end
