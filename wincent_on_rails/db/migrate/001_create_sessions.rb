# this file created using "rake db:sessions:create"
# must also uncomment "config.action_controller.session_store = :active_record_store" in environment.rb
class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string      :session_id, :null => false
      t.text        :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end

  def self.down
    drop_table :sessions
  end
end
