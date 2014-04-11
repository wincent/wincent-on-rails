class Post < ActiveRecord::Base
  PAGE_SIZE = 10

  has_many                :comments,
                          -> { includes(:user).order('comments.created_at') },
                          as:        :commentable,
                          extend:    Commentable,
                          dependent: :destroy
  belongs_to              :last_commenter, class_name: 'User'
  validates_presence_of   :title
  validates_format_of     :permalink,
                          with: /\A[a-z0-9\.\-]+\z/,
                          message: 'must contain only lowercase letters, numbers, periods and hyphens'
  validates_presence_of   :permalink
  validates_uniqueness_of :permalink
  validates_presence_of   :excerpt
  validates_length_of     :body, maximum: 128 * 1024, allow_blank: true
  attr_accessible         :title, :permalink, :excerpt, :body, :public,
                          :accepts_comments, :pending_tags
  before_validation       :set_permalink

  scope :published, -> { where(public: true) }
  scope :recent,    -> { published.order('created_at DESC') }
  scope :page,      -> { limit(PAGE_SIZE) }

  acts_as_taggable
  acts_as_searchable      attributes: %i[title excerpt body]

  def suggested_permalink
    # iconv can't be trusted to behave the same across platforms, so don't use
    # it this doesn't handle non-ASCII characters very well (they just get
    # eaten), but for my uses it will be fine
    base = title ? title.downcase.split(/[^a-z0-9\.]+/).join('-') : ''
    if base.length == 0
      # handle pathological case
      base = id.nil? ? 'post' : id.to_s
    end

    # now need to make sure it is unique
    # there is a race here, but it is harmless for two reasons:
    # - I am the only user creating articles
    # - if the proposed permalink is not unique validation will fail and the
    #   user can correct the problem
    # worst case scenario is that validation passes and then the database-level
    # constraint kicks in
    last =  Post.where(['permalink REGEXP ?', "^#{base}(-[0-9]+)?$"]).
      order('permalink').last
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
    (changes['permalink'] && changes['permalink'].first) || permalink
  end

private

  def set_permalink
    if permalink.blank?
      self.permalink = self.suggested_permalink
    end
  end
end
