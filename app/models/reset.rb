require 'digest/sha1'

# TODO: seeing as there is some overlap with the Confirmation model,
# consider extracting some methods into a common abstract superclass
class Reset < ActiveRecord::Base
  belongs_to            :user
  validates_presence_of :email_address, :on => :update
  validates_each        :email_address, :on => :update do |reset, att, value|
    # guard against brute force attacks by requiring the user to supply an associated email address
    unless reset.user.emails.find :first, :conditions => { :address => value }
      reset.errors.add(att, 'must match existing email on record')
    end
  end

  attr_accessor         :email_address
  attr_accessible       :email_address

  SECRET_SALT = '124f1e6487ab214cb155db238cf1765d9c972d35'
  def self.secret
    Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s + SECRET_SALT)
  end

  def before_save
    self.secret = Reset.secret if self.secret.blank?
    self.cutoff = 3.days.from_now if self.cutoff.nil?
  end

  def to_param
    secret
  end
end
