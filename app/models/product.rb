class Product < ActiveRecord::Base
  has_many                :pages, :dependent => :destroy
  default_scope           :order => 'category, position'
  validates_presence_of   :name, :permalink
  validates_uniqueness_of :name, :permalink
  validates_format_of     :permalink, :with => /\A[a-z0-9\-]+\z/i,
    :message => 'may only contain lowercase letters, numbers and hypens'
  validates_uniqueness_of :bundle_identifier, :allow_blank => true
  after_save              :process_icon
  after_destroy           :cleanup_icons
  attr_accessible         :category, :name, :permalink, :position,
    :bundle_identifier, :description, :footer, :header, :icon,
    :hide_from_front_page
  # TODO: acts_as_searchable :attributes => [:footer, :header] (will require HTML tokenization)

  # path on disk relative to application root
  ICON_DIR  = 'public/system/products/icons'

  # path for use when constructing URLs
  ICON_PATH = '/system/products/icons'

  # returns ordered hash of all products organized by categories
  def self.categorized_products
    all(:conditions => { :hide_from_front_page => false }).group_by(&:category)
  end

  def before_save
    # empty strings might falsely trigger database-level uniqueness constraint
    self.bundle_identifier = nil if self.bundle_identifier.blank?
  end

  def icon= icon
    # if no icon was supplied file_field will pass a StringIO object
    return unless icon.respond_to? :original_filename
    extension = icon.original_filename.split('.').last.downcase
    if ['gif', 'jpg', 'jpeg', 'png'].include? extension
      @icon = icon
      write_attribute 'icon_extension', extension
    end
  end

  def icon_path
    File.exist?(icon_path_on_disk) ? "#{ICON_PATH}/#{icon_filename}" : nil
  end

  def to_param
    self.permalink
  end

private

  def icon_filename
    "#{self.permalink}.#{self.icon_extension}"
  end

  # Absolute path to icon on disk
  def icon_path_on_disk
    File.join(Rails.root, ICON_DIR, icon_filename)
  end

  def write_icon
    File.open(icon_path_on_disk, 'w') do |file|
      file.puts @icon.read
    end
  end

  def process_icon
    if @icon
      cleanup_icons # deletes old icon(s)
      write_icon
      @icon = nil
    end
  end

  def cleanup_icons
    Dir[File.join(ICON_DIR, "#{self.permalink}.*")].each do |filename|
      File.unlink(filename) rescue nil
    end
  end
end
