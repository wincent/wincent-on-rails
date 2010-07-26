class CreateRepos < ActiveRecord::Migration
  def self.up
    create_table :repos do |t|
      t.string :name,         :null => false
      t.string :permalink,    :null => false
      t.string :path,         :null => false
      t.string :description
      t.integer :product_id
      t.boolean :public,      :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :repos
  end
end
