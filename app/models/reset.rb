require 'digest/sha1'

# Table fields:
#
#   string      :secret
#   datetime    :cutoff
#   integer     :email_id
#   datetime    :completed_at
#   timestamps
#
# TODO: add a :null => false constraint to the email_id column
#
# TODO: seeing as there is some overlap with the Confirmation model,
# consider extracting some methods into a common abstract superclass
class Reset < ActiveRecord::Base
  belongs_to            :email
  validates_presence_of :email
  validates_presence_of :email_address, :on => :update
  validates_each        :email_address, :on => :update do |reset, att, value|
    # guard against brute force attacks
    unless value == reset.email.address
      reset.errors.add(att, 'must match existing email on record')
    end
  end
  before_create         :set_secret_and_cutoff

  attr_accessor         :email_address
  attr_accessible       :email_address

  SECRET_SALT = '124f1e6487ab214cb155db238cf1765d9c972d35'
  def self.secret
    Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s + SECRET_SALT)
  end

  def to_param
    secret
  end

private

  def set_secret_and_cutoff
    self.secret = Reset.secret if secret.blank?
    self.cutoff = 3.days.from_now if cutoff.nil?
  end
end
