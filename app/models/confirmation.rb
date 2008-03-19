require 'digest'

class Confirmation < ActiveRecord::Base
  belongs_to :email

  SECRET_SALT = '96218e6ec4622f8aae7248c003154997bcace26e'
  def self.secret
    Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s + SECRET_SALT)
  end

  def before_save
    self.secret = Confirmation.secret if self.secret.blank?
    self.cutoff = 3.days.from_now if self.cutoff.nil?
  end

  def to_param
    secret
  end
end
