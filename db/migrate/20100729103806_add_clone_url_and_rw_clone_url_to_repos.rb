class AddCloneUrlAndRwCloneUrlToRepos < ActiveRecord::Migration
  def self.up
    add_column :repos, :clone_url, :string
    add_column :repos, :rw_clone_url, :string
  end

  def self.down
    remove_column :repos, :rw_clone_url
    remove_column :repos, :clone_url
  end
end
