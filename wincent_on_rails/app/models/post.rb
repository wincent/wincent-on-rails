class Post < ActiveRecord::Base
  has_many                :comments, :as => :commentable, :extend => Commentable
  validates_presence_of   :title
  validates_format_of     :permalink, :with => /\A[a-z\-]+\z/, :if => Proc.new { |p| !p.permalink.blank? },
    :message => 'must contain only lowercase letters and hypens'
  validates_presence_of   :permalink
  validates_uniqueness_of :permalink
  validates_presence_of   :excerpt

  acts_as_taggable

  # doesn't work because the accessor will always return only valid values
  #validates_format_of     :pending_tags, :with => /\A[a-z \.]*\z/, :message => 'may only contain letters or periods'

  # too late as well: by the time this is called we have already run the after_save filter, which effectively clean up the tags
  #validates_associated  :tags

  def before_validation
    if permalink.blank?
      # come up with own permalink
      title.downcase.gsub(/\W+/, '-') # but need to make sure it is unique...
    end
    true
  end

  def to_param
    if permalink and !permalink.blank?
      permalink
    else
      id
    end
  end
end
