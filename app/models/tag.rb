class Tag < ActiveRecord::Base
  has_many                :taggings
  has_many                :taggables, :through => :taggings
  validates_presence_of   :name
  validates_format_of     :name,
                          :with => /\A[a-z]+(\.[a-z]+)*\z/i,
                          :message => 'may only contain letters with words separated by periods'
  validates_uniqueness_of :name
  attr_accessible         :name

  # returns a floating point number between 0 and 1 to denote a tag's relative popularity
  def normalized_taggings_count
    max = Tag.maximum(:taggings_count) # the Rails query cache will cache this
    min = Tag.minimum(:taggings_count) # the Rails query cache will cache this
    range = max - min
    count = self.taggings_count
    (count - min).to_f / range
  end

  # normalize tag names to lowercase
  def name= string
    super(string ? string.downcase : string)
  end

  def to_param
    name
  end
end
