# A Tweet is a short textual update. It is recommended that it be
# kept short (140 characters or less, like on Twitter), but this
# limit is not actually enforced.
#
# Schema:
#
#  `id` int(11) NOT NULL AUTO_INCREMENT,
#  `body` text COLLATE utf8_unicode_ci,
#  `created_at` datetime DEFAULT NULL,
#  `updated_at` datetime DEFAULT NULL,
#  `accepts_comments` tinyint(1) DEFAULT '1',
#  `comments_count` int(11) DEFAULT '0',
#  `last_commenter_id` int(11) DEFAULT NULL,
#  `last_comment_id` int(11) DEFAULT NULL,
#  `last_commented_at` datetime DEFAULT NULL,
#  `twitter_id` bigint(20) DEFAULT NULL,
#  `twitter_id_str` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
#
class Tweet < ActiveRecord::Base
  RECOMMENDED_MAX_LENGTH = 140
  has_many              :comments,
                        :as               => :commentable,
                        :extend           => Commentable,
                        :order            => 'comments.created_at',
                        :include          => :user,
                        :dependent        => :destroy
  belongs_to            :last_commenter,  :class_name => 'User'
  validates_presence_of :body
  acts_as_searchable    :attributes       => [ :body ]
  acts_as_taggable
  attr_accessible       :accepts_comments, :body, :pending_tags

  def self.find_recent options = {}
    base_options = { :order => 'created_at DESC', :limit => 20 }
    find :all, base_options.merge(options)
  end

  # legal path chars: http://tools.ietf.org/html/rfc3986#section-1.1.1
  SHORT_LINK_CHARS = [
    '0'..'9',
    'a'..'z',
    'A'..'Z',
    "=.,;:@!$&'()*+~_-".chars,
  ].map(&:to_a).join

  SHORT_LINK_BASE  = SHORT_LINK_CHARS.size
  SHORT_LINK_MAP   = Hash[SHORT_LINK_CHARS.chars.zip(0..SHORT_LINK_BASE)]
  SHORT_LINK_REGEX = /[#{Regexp.escape(SHORT_LINK_CHARS)}]+/

  def self.short_link_from_id(id)
    result = ''

    while id > 0
      result = SHORT_LINK_CHARS[id % SHORT_LINK_BASE] + result
      id /= SHORT_LINK_BASE
    end

    result
  end

  def self.id_from_short_link(id)
    result = 0

    id.chars.each do |char|
      # no need to check #has_key? here; trust the routes to keep out bad input
      result = result * SHORT_LINK_BASE + SHORT_LINK_MAP[char]
    end

    result
  end

  def short_link
    # note: will raise for new records
    self.class.short_link_from_id(id)
  end

  def overlength?
    rendered_length > RECOMMENDED_MAX_LENGTH
  end

  @@sanitizer = nil
  def sanitize html
    @@sanitizer ||= HTML::FullSanitizer.new
    @@sanitizer.sanitize html
  end

  def rendered_length
    sanitize(body.w).chomp.length
  end
end
