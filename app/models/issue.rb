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
  validates_presence_of   :summary
  validates_presence_of   :description
  validates_inclusion_of  :kind,    :in => KIND_MAP.keys,   :message => 'not a valid kind code'
  validates_inclusion_of  :status,  :in => STATUS_MAP.keys, :message => 'not a valid status code'
  attr_accessible         :summary, :description, :public, :product_id, :kind
  acts_as_taggable

  include Classifiable

  def status_string
    STATUS_MAP[self.status].to_s.humanize
  end

  def kind_string
    KIND_MAP[self.kind].to_s.humanize
  end

  def visible_comments
    # can't use the Commentable association mixin methods here because we need to specify an :include clause
    conditions = { :public => true, :awaiting_moderation => false, :spam => false, :commentable_id => self.id,
      :commentable_type => 'Issue' }
    Comment.find :all, :conditions => conditions, :include => 'user', :order => 'comments.created_at'
  end

  def self.update_timestamps_for_comment_changes?
    true
  end
end
