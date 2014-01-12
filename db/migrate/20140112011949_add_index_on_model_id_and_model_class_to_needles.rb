class AddIndexOnModelIdAndModelClassToNeedles < ActiveRecord::Migration
  def change
    add_index :needles, [:model_id, :model_class]
  end
end
