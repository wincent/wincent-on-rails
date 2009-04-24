class AddBundleIdentifierToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :bundle_identifier, :string, :null => true
  end

  def self.down
    remove_column :products, :bundle_identifier
  end
end
