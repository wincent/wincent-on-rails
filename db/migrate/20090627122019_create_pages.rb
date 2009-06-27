class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string  :title,                         :null => false
      t.string  :permalink,                     :null => false
      t.text    :body,      :default => '',     :null => false
      t.boolean :front,     :default => false,  :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
