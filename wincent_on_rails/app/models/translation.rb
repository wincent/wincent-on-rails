class Translation < ActiveRecord::Base
  belongs_to              :locale
  validates_uniqueness_of :key,     :scope => 'locale_id'
end
