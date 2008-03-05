class Product < ActiveRecord::Base
  validates_presence_of   :name, :permalink
  validates_uniqueness_of :name, :permalink

  def to_param
    self.permalink
  end
end
