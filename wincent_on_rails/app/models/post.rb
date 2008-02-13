class Post < ActiveRecord::Base
  has_many                :comments, :as => :commentable
  validates_presence_of   :title
  validates_format_of     :permalink, :with => /\A[a-z\-]+\z/, :if => Proc.new { |p| !p.permalink.blank? },
    :message => 'must contain only lowercase letters and hypens'
  validates_presence_of   :permalink
  validates_uniqueness_of :permalink
  validates_presence_of   :excerpt
  acts_as_taggable

  # def before_save
  #   if permalink.blank?
  #     permalink = title
  #   end
  # end

  def to_param
    if permalink and !permalink.blank?
      permalink
    else
      id
    end
  end
end
