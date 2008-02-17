class Post < ActiveRecord::Base
  has_many                :comments, :as => :commentable, :extend => Commentable
  validates_presence_of   :title
  validates_format_of     :permalink, :with => /\A[a-z0-9\.\-]+\z/,
    :message => 'must contain only lowercase letters, numbers, periods and hypens'
  validates_presence_of   :permalink
  validates_uniqueness_of :permalink
  validates_presence_of   :excerpt

  acts_as_taggable

  def before_validation
    if permalink.blank?
      self.permalink = self.suggested_permalink
    end
    true
  end

  def suggested_permalink
    # iconv can't be trusted to behave the same across platforms, so don't use it
    # this doesn't handle non-ASCII characters very well (they just get eaten), but for my uses it will be fine
    base = title.downcase.split(/[^a-z0-9\.]+/).join('-')
    if base.length == 0
      # handle pathological case
      base = id.nil? ? 'post' : id.to_s
    end

    # now need to make sure it is unique
    # there is a race here, but seeing as I am the only user creating articles it is not a problem
    last =  Post.find(:first, :conditions => ['permalink LIKE ?', "#{base}%"], :order => 'permalink DESC')
    if last.nil?
      base
    else
      if last.permalink =~ /\-(\d+)$/
        num = $~[1].to_i + 1
      else
        num = 2
      end
      "#{base}-#{num}"
    end
  end

  def to_param
    permalink
  end
end
