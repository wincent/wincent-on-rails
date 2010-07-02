class RemoveUserIdFromResets < ActiveRecord::Migration
  def self.up
    remove_column :resets, :user_id
  end

  def self.down
    add_column :resets, :user_id, :integer, :null => false

    Reset.all.each do |reset|
      # can't use "update" here as its validations will fail
      Reset.update_all({ :user_id => reset.email.user.id }, { :id => reset.id })
    end
  end
end
