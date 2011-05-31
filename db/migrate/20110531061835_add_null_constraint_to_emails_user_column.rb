class AddNullConstraintToEmailsUserColumn < ActiveRecord::Migration
  def up
    change_column :emails, :user_id, :integer, :null => false
  end

  def down
    change_column :emails, :user_id, :integer, :null => true
  end
end
