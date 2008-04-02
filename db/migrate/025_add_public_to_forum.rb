class AddPublicToForum < ActiveRecord::Migration
  class Forum < ActiveRecord::Base; end
  def self.up
    add_column :forums, :public, :boolean, :default => true, :null => false
    Forum.update_all 'public = TRUE'
  end

  def self.down
    remove_column :forums, :public
  end
end
