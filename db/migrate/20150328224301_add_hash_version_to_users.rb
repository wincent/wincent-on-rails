class AddHashVersionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hash_version, :integer, default: 1
    User.update_all 'hash_version = 0'
  end
end
