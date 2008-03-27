class Email < ActiveRecord::Base
  belongs_to              :user
  has_many                :confirmations, :dependent => :destroy
  validates_presence_of   :address
  validates_uniqueness_of :address
  validates_format_of     :address, :with => /[a-z0-9\.\_\-]+@([a-z0-9\-]+\.)+[a-z]{2,6}/i,
    :message => 'must be of the form user@host.domain'

  def to_param
    address
  end
end
