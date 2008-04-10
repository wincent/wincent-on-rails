class Issue < ActiveRecord::Base
  STATUS      = Hash.new(0).merge!({ :new => 0, :open => 1, :closed => 2 }).freeze
  STATUS_MAP  = STATUS.invert.freeze
  KIND        = Hash.new(0).merge!({ :bug => 0, :feature_request => 1, :support_ticket => 2, :feedback => 3 }).freeze
  KIND_MAP    = KIND.invert.freeze

  belongs_to              :user
  belongs_to              :last_commenter, :class_name => 'User'
  belongs_to              :product
  has_many                :comments,
                          :as         => :commentable,
                          :extend     => Commentable,
                          :order      => 'comments.created_at',
                          :include    => :user,
                          :dependent  => :destroy
  has_many                :monitorships, :as => :monitorable, :dependent => :destroy
  validates_inclusion_of  :status, :in => STATUS_MAP.keys, :message => 'not a valid status code'
  attr_accessible         :summary, :status, :description # and probably more to come
  acts_as_taggable

  def status_string
    STATUS_MAP[self.status].to_s.humanize
  end

  def kind_string
    KIND_MAP[self.kind].to_s.humanize
  end

  # When updating issue status from untrusted form parameters using the "update_attribute" method
  # validations are not triggered. We could do sanity checks in the controller but it's slightly
  # cleaner if we do it in the model instead. Here we explicitly perform validation before calling
  # "update_attribute", returning true on success and false on failure; the controller is then
  # free to return an appropriate status code (200 for success, 422 for failure).
  def update_status string
    new_status  = string.to_i
    self.status = new_status
    return false if !errors[:status].nil?
    update_attribute :status, new_status
    true
  end

  def self.update_timestamps_for_comment_changes?
    true
  end
end
