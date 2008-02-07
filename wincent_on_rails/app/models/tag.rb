class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :taggables, :through => :taggings

  # returns a floating point number between 0 and 1 to denote a tag's relative popularity
  def normalized_taggings_count
    max = Tag.maximum(:taggings_count) # the Rails query cache will cache this
    min = Tag.minimum(:taggings_count) # the Rails query cache will cache this
    range = max - min
    count = self.taggings_count
    (count - min).to_f / range
  end

  def to_param
    self.name
  end
end
