class RemoveTimeStampsFromNeedle < ActiveRecord::Migration
  def self.up
    remove_column :needles, :created_at
    remove_column :needles, :updated_at
  end

  def self.down
    # there's really no going back from here, but to maintain a semblance of symmetry...
    add_column  :needles, :created_at, :datetime
    add_column  :needles, :updated_at, :datetime
  end
end
