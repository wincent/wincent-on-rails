class Post < ActiveRecord::Base
  has_many                :comments, :as => :commentable, :extend => Commentable, :order => 'created_at ASC'
  belongs_to              :last_commenter, :class_name => 'User'
  validates_presence_of   :title
  validates_format_of     :permalink, :with => /\A[a-z0-9\.\-]+\z/,
    :message => 'must contain only lowercase letters, numbers, periods and hypens'
  validates_presence_of   :permalink
  validates_uniqueness_of :permalink
  validates_presence_of   :excerpt

  acts_as_taggable
  acts_as_searchable      :attributes => [:title, :excerpt, :body]

  def self.find_recent options = {}
    # we use "posts.created_at" rather than just "created_at" to disambiguate in the case where we
    # pass an :include option (which will cause a join)
    base_options = {:conditions => {'public' => true}, :order => 'posts.created_at DESC', :limit => 10}
    find(:all, base_options.merge(options))
  end

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
    # there is a race here, but it is harmless for two reasons:
    # - I am the only user creating articles
    # - if the proposed permalink is not unique validation will fail and the user can correct the problem
    # worst case scenario is that validation passes and then the database-level constraint kicks in
    last =  Post.find(:first, :conditions => ['permalink REGEXP ?', "^#{base}(-[0-9]+)?$"], :order => 'permalink DESC')
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
