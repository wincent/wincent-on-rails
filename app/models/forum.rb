class Forum < ActiveRecord::Base
  has_many                :topics, :order => 'topics.updated_at DESC', :dependent => :destroy
  validates_presence_of   :name
  validates_format_of     :name, :with => /\A[a-z ]+\z/i, :message => 'may only contain letters and spaces'
  validates_uniqueness_of :name

  def self.find_with_param! param
    # forum name will be downcased in the URL, but MySQL will do a case-insensitive search for us anyway
    find_by_name(deparametrize(param)) || (raise ActiveRecord::RecordNotFound)
  end

  def self.deparametrize string
    string.gsub '-', ' '
  end

  def self.parametrize string
    string.downcase.gsub ' ', '-'
  end

  def to_param
    Forum.parametrize name
  end
end
