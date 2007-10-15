class Status < ActiveRecord::Base
  MINIMUM_STATUS_NAME_LENGTH  = 3

  #acts_as_list
  has_many                :issues
  #attr_accessible         :name, :description, :closed, :default
  validates_presence_of   :name
  validates_uniqueness_of :name
  validates_length_of     :name, :minimum => MINIMUM_STATUS_NAME_LENGTH

  # Returns the default status (used for new issues) from the database.
  # If there is no default status returns the first status in the database.
  def self.default
    # minor race condition here: in the interval between unsetting old default and setting new one there will be no default
    find_by_is_default(true) || find(:first)
  end

  def before_save
    if self.is_default?
      Status.update_all 'is_default = false'
    elsif self == Status.default
      errors.add_to_base 'Cannot unset default status'
      return false
    end
    true
  end

  def before_destroy
    if Issue.find_by_status_id(self.id)
      errors.add_to_base 'Cannot delete status (currently in use)'
      return false
    end
    if self.is_default?
      errors.add_to_base 'Cannot delete the default status'
      return false
    end
    true
  end

end
