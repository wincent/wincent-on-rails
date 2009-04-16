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
  validates_presence_of :body
  acts_as_searchable :attributes => [ :body ]
  attr_accessible :body

  def self.find_recent paginator = nil
    options = { :order => 'created_at DESC', :limit => 20 }
    options.merge!({ :offset => paginator.offset, :limit => paginator.limit }) if paginator
    find :all, options
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
