class Issue < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :status
  has_many    :comments,  :as => :commentable
  has_many    :taggings,  :as => :taggable
  has_many    :tags,      :through => :taggings

  def before_validation
    self.status = Status.default if new_record?
  end

end
