require 'securerandom'

class Confirmation < ActiveRecord::Base
  belongs_to :email
  set_callback :create, :before, :set_secret_and_cutoff

  def self.secret
    SecureRandom::hex(20)
  end

  def to_param
    secret
  end

private

  def set_secret_and_cutoff
    self.secret = Confirmation.secret if secret.blank?
    self.cutoff = 3.days.from_now if cutoff.nil?
  end
end
