# A Tweet is a short textual update. It is recommended that it be
# kept short (140 characters or less, like on Twitter), but this
# limit is not actually enforced.
#
# Table fields:
#
#   text        :body
#   timestamps
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
  attr_accessible       :body,            :pending_tags

  def self.find_recent options = {}
    base_options = { :order => 'created_at DESC', :limit => 20 }
    find :all, base_options.merge(options)
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
