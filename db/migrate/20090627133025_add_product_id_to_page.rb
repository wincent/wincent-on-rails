class AddProductIdToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :product_id, :integer
  end

  def self.down
    remove_column :pages, :product_id
  end
end
