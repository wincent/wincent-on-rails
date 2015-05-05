# Schema:
#
#   string   "description"
#   integer  "markup_type",       :default => 0
#   text     "body"
#   datetime "created_at"
#   datetime "updated_at"
#   boolean  "public",            :default => true
#   integer  "comments_count",    :default => 0
#   boolean  "accepts_comments",  :default => true
#
# TODO: make this model searchable like the other ones
class Snippet < ActiveRecord::Base
  module MarkupType
    # base types
    WIKITEXT    = 0
    PLAINTEXT   = 1
    HTML        = 2

    # syntax-highlighted types
    C           = 100
    DIFF        = 200
    OBJECTIVE_C = 300
    RUBY        = 400
    SHELL       = 500
  end

  MARKUP_TYPES = Hash.new(0).merge!({
    'Wikitext'    => MarkupType::WIKITEXT,
    'Plain text'  => MarkupType::PLAINTEXT,
    'HTML'        => MarkupType::HTML,
    'C'           => MarkupType::C,
    'Diff'        => MarkupType::DIFF,
    'Objective-C' => MarkupType::OBJECTIVE_C,
    'Ruby'        => MarkupType::RUBY,
    'Shell'       => MarkupType::SHELL
  }).freeze

  acts_as_taggable

  attr_accessible :accepts_comments, :body, :description, :markup_type,
    :pending_tags, :public

  belongs_to :last_commenter, class_name: 'User'

  has_many  :comments,
            -> { includes(:user).order('comments.created_at') },
            as:        :commentable,
            extend:    Commentable,
            dependent: :destroy

  scope :published, -> { where(public: true) }
  scope :recent,    -> { published.order('updated_at DESC').limit(10) }

  validates_presence_of :body
  validates_inclusion_of :markup_type,
    in:      MARKUP_TYPES.values,
    message: 'not a valid markup type'

  def body_html options = {}
    case markup_type
    when MarkupType::WIKITEXT
      body.w options
    when MarkupType::PLAINTEXT
      escape_and_wrap_body
    when MarkupType::HTML
      body.html_safe
    when MarkupType::C
      escape_and_wrap_body 'c'
    when MarkupType::DIFF
      escape_and_wrap_body 'diff'
    when MarkupType::OBJECTIVE_C
      escape_and_wrap_body 'objc'
    when MarkupType::RUBY
      escape_and_wrap_body 'ruby'
    when MarkupType::SHELL
      escape_and_wrap_body 'shell'
    else # unlikely to get here (due to validations)
      raise "Unknown markup type #{markup_type}"
    end
  end

private

  include ERB::Util

  def escape_and_wrap_body lang = nil
    if lang
      %Q{<pre class="#{lang}-syntax">#{h body}</pre>\n}
    else
      %Q{<pre>#{h body}</pre>\n}
    end.html_safe
  end
end
