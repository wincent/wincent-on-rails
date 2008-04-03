class Email < ActiveRecord::Base
  belongs_to              :user
  has_many                :confirmations, :dependent => :destroy
  validates_presence_of   :address
  validates_uniqueness_of :address
  validates_format_of     :address,
                          :with => /[a-z0-9\.\_\-]+@([a-z0-9\-]+\.)+[a-z]{2,6}/i,
                          :message => 'must be of the form user@host.domain'
  attr_accessible         :address, :verified, :deleted # only the admin can touch these (see the emails controller)

  def deleted= flag
    # If coming from a form, flag will be a String ('0' or '1').
    bool = (flag == '1')
    if bool && !deleted?
      self.deleted_at = Time.now
    elsif !bool
      self.deleted_at = nil
    end
  end

  def deleted
    !deleted_at.nil?
  end
  alias_method :deleted?, :deleted

  def to_param
    address
  end
end
