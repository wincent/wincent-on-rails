class AddEmailIdToReset < ActiveRecord::Migration
  def self.up
    add_column :resets, :email_id, :integer

    # currently only have about 30 of these in production database
    Reset.all.each do |reset|
      default_email = reset.user.emails.first :conditions => { :default => true }
      reset.email   = default_email

      # bypass normal update validation here
      # (which requires an email_address virtual attribute)
      reset.save_with_validation(false)
    end
  end

  def self.down
    remove_column :resets, :email_id
  end
end
