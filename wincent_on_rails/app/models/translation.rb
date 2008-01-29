class Translation < ActiveRecord::Base
  belongs_to              :locale
  validates_presence_of   :key
  validates_presence_of   :translation
  validates_uniqueness_of :key, :scope => 'locale_id'
end
