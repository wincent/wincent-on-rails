class CreateNeedles < ActiveRecord::Migration
  def self.up

    # our home-made full text index consists of "needles" (words) to be found in the "haystack" (the application)
    # this does involve duplication of data so will need to benchmark this to see if is worth it
    create_table :needles do |t|
      t.string  :model_class,     :null => false
      t.integer :model_id,        :null => false
      t.string  :attribute_name,  :null => false
      t.string  :content,         :null => false
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :needles
  end
end
