class Product < ActiveRecord::Base
  has_many                :pages, :dependent => :destroy
  default_scope           :order => 'category, position'
  validates_presence_of   :name, :permalink
  validates_uniqueness_of :name, :permalink
  validates_format_of     :permalink, :with => /\A[a-z0-9\-]+\z/i,
    :message => 'may only contain lowercase letters, numbers and hypens'
  validates_uniqueness_of :bundle_identifier, :allow_blank => true
  before_save             :set_bundle_identifier
  attr_accessible         :category, :name, :permalink, :position,
    :bundle_identifier, :description, :footer, :header,
    :hide_from_front_page
  # TODO: acts_as_searchable :attributes => [:footer, :header] (will require HTML tokenization)

  # returns ordered hash of all products organized by categories
  def self.categorized_products
    all(:conditions => { :hide_from_front_page => false }).group_by(&:category)
  end

  def to_param
    self.permalink
  end

private

  def set_bundle_identifier
    # empty strings might falsely trigger database-level uniqueness constraint
    self.bundle_identifier = nil if self.bundle_identifier.blank?
  end
end
