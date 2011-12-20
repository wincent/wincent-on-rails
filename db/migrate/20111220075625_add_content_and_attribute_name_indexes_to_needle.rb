class AddContentAndAttributeNameIndexesToNeedle < ActiveRecord::Migration
  def change
    add_index :needles, [:content, :attribute_name]
  end
end
