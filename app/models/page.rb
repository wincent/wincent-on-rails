class Page < ActiveRecord::Base
  belongs_to            :product
  validates_presence_of :title
  validates_presence_of :permalink
  validates_format_of   :permalink, :with => /\A[a-zA-Z0-9\-]+\z/,
                        :message => 'must only contain letters, numbers and hyphens'
  attr_accessible       :title, :permalink, :body, :front
  # TODO: acts_as_searchable :attributes => [:body, :title] (will require HTML tokenization)

  def to_param
    self.permalink
  end
end
