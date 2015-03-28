class AddHashVersionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hash_version, :integer, default: 0
  end
end
