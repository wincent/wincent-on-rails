# Schema:
#
#   string   "description"
#   integer  "markup_type",    :default => 0
#   text     "body"
#   datetime "created_at"
#   datetime "updated_at"
#   boolean  "public",         :default => true
#   integer  "comments_count", :default => 0
class Snippet < ActiveRecord::Base
  module MarkupType
    # base types
    WIKITEXT    = 0
    PLAINTEXT   = 1

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
    'C'           => MarkupType::C,
    'Diff'        => MarkupType::DIFF,
    'Objective-C' => MarkupType::OBJECTIVE_C,
    'Ruby'        => MarkupType::RUBY,
    'Shell'       => MarkupType::SHELL
  }).freeze

  validates_presence_of :body
  validates_inclusion_of :markup_type,
    :in => MARKUP_TYPES.values,
    :message => 'not a valid markup type'
  attr_accessible :body, :description, :markup_type, :public

  def body_html
    case markup_type
    when MarkupType::WIKITEXT
      body.w
    when MarkupType::PLAINTEXT
      escape_and_wrap_body
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
