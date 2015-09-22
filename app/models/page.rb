class Page < ActiveRecord::Base
  module MarkupType
    HTML      = 0
    WIKITEXT  = 1
  end
  MARKUP_TYPES = Hash.new(0).merge!({
    'HTML' => MarkupType::HTML,
    'Wikitext' => MarkupType::WIKITEXT
  }).freeze

  belongs_to              :product
  validates_presence_of   :title
  validates_presence_of   :permalink
  validates_format_of     :permalink, :with => /\A[a-zA-Z0-9\-]+\z/,
                          :message => 'must only contain letters, numbers and hyphens'
  validates_presence_of   :body
  validates_inclusion_of  :markup_type,
                          :in => MARKUP_TYPES.values,
                          :message => 'not a valid markup type'
  attr_accessible         :title, :permalink, :body, :markup_type, :front

  def to_param
    (changes['permalink'] && changes['permalink'].first) || permalink
  end

  def body_html
    case markup_type
    when MarkupType::HTML
      body.html_safe
    when MarkupType::WIKITEXT
      body.w
    else # unlikely to get here (due to validations)
      raise "Unknown markup type #{markup_type}"
    end
  end
end
