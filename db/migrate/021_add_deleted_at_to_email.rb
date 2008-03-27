class AddDeletedAtToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :deleted_at, :datetime, :null => true
  end

  def self.down
    remove_column :emails, :deleted_at
  end
end
