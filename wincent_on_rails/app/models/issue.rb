class Issue < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :status
  has_many    :comments,  :as => :commentable
  acts_as_taggable

  def before_validation
    self.status = Status.default if new_record?
  end

end
