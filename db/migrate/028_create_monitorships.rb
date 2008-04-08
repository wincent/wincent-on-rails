class CreateMonitorships < ActiveRecord::Migration
  def self.up
    create_table :monitorships do |t|
      t.integer     :user_id,           :null => false
      t.integer     :monitorable_id,    :null => false # polymorphic
      t.string      :monitorable_type,  :null => false # polymorphic
      t.timestamps
    end
  end

  def self.down
    drop_table :monitorships
  end
end
