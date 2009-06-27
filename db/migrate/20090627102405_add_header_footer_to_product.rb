class AddHeaderFooterToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :header, :text, :default => '', :null => false
    add_column :products, :footer, :text, :default => '', :null => false
    Product.update_all "header = ''"
    Product.update_all "footer = ''"
  end

  def self.down
    remove_column :products, :footer
    remove_column :products, :header
  end
end
