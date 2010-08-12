class AddIndexesToRepos < ActiveRecord::Migration
  def self.up
    # database-level constraints to ensure uniquess
    # (validates_uniqueness_of is vulnerable to races)
    add_index :repos, :clone_url,     :unique => true
    add_index :repos, :name,          :unique => true
    add_index :repos, :path,          :unique => true
    add_index :repos, :permalink,     :unique => true
    add_index :repos, :product_id,    :unique => true
    add_index :repos, :rw_clone_url,  :unique => true
  end

  def self.down
    remove_index :repos, :column => :clone_url
    remove_index :repos, :column => :name
    remove_index :repos, :column => :path
    remove_index :repos, :column => :permalink
    remove_index :repos, :column => :product_id
    remove_index :repos, :column => :rw_clone_url
  end
end
