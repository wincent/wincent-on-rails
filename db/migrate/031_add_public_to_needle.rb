class AddPublicToNeedle < ActiveRecord::Migration
  def self.up
    add_column :needles, :public, :boolean, :null => true # can be TRUE/FALSE/NULL (public/private/unspecified)
  end

  def self.down
    remove_column :needles, :public
  end
end
