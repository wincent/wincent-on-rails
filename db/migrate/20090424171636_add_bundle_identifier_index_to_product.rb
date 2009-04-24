class AddBundleIdentifierIndexToProduct < ActiveRecord::Migration
  def self.up
    add_index :products, :bundle_identifier, :unique => true
  end

  def self.down
    remove_index :products, :column => :bundle_identifier
  end
end
