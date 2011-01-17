class Product < ActiveRecord::Base
  has_many                :pages, :dependent => :destroy
  default_scope           :order => 'category, position'
  scope                   :front_page, where(:hide_from_front_page => false)

  validates_presence_of   :name, :permalink
  validates_uniqueness_of :name, :permalink
  validates_format_of     :permalink, :with => /\A[a-z0-9\-]+\z/i,
    :message => 'may only contain lowercase letters, numbers and hyphens'
  validates_uniqueness_of :bundle_identifier, :allow_blank => true
  before_save             :check_optional_attributes
  attr_accessible         :category, :name, :permalink, :position,
    :bundle_identifier, :description, :footer, :header,
    :hide_from_front_page
  # TODO: acts_as_searchable :attributes => [:footer, :header] (will require HTML tokenization)

  # Returns ordered hash of all products organized by categories
  def self.categorized
    all.group_by(&:category)
  end

  def to_param
    (changes['permalink'] && changes['permalink'].first) || permalink
  end

private

  def check_optional_attributes
    # empty strings for optional attributes will falsely trigger database-level
    # uniqueness constraints, so replace empty strings with nil
    self.bundle_identifier = nil if self.bundle_identifier.blank?
  end
end
