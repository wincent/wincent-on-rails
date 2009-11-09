class Page < ActiveRecord::Base
  module MarkupType
    HTML      = 0
    WIKITEXT  = 1
  end
  MARKUP_TYPES = Hash.new(0).merge!({ 'HTML' => MarkupType::HTML, 'Wikitext' => MarkupType::WIKITEXT }).freeze

  belongs_to              :product
  validates_presence_of   :title
  validates_presence_of   :permalink
  validates_format_of     :permalink, :with => /\A[a-zA-Z0-9\-]+\z/,
                          :message => 'must only contain letters, numbers and hyphens'
  validates_inclusion_of  :markup_type,
                          :in => [ MarkupType::HTML, MarkupType::WIKITEXT ]
  attr_accessible         :title, :permalink, :body, :markup_type, :front
  # TODO: acts_as_searchable :attributes => [:body, :title] (will require HTML tokenization)

  def to_param
    self.permalink
  end

  def body_html
    case markup_type
    when MarkupType::HTML
      body
    when MarkupType::WIKITEXT
      body.w
    else # unlikely to get here (due to validations)
      raise "Unknown markup type #{markup_type}"
    end
  end
end
