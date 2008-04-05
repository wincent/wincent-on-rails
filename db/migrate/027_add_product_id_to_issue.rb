class AddProductIdToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :product_id, :integer, :default => nil, :null => true
  end

  def self.down
    remove_column :issues, :product_id
  end
end
