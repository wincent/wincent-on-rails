class AddHideFromFrontPageToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :hide_from_front_page, :boolean, :default => true
    Product.update_all 'hide_from_front_page = TRUE'
  end

  def self.down
    remove_column :products, :hide_from_front_page
  end
end
