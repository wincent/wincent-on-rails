class Page < ActiveRecord::Base
  module MarkupType
    HTML      = 0
    WIKITEXT  = 1
  end

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

  def html?
    self.markup_type == MarkupType::HTML
  end

  def wikitext?
    self.markup_type == MarkupType::WIKITEXT
  end
end
