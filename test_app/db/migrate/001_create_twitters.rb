class CreateTwitters < ActiveRecord::Migration
  def self.up
    create_table :twitters do |t|
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :twitters
  end
end
