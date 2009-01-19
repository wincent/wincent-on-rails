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
  validates_length_of     :description, :maximum => 128 * 1024
  validates_inclusion_of  :kind,    :in => KIND_MAP.keys,   :message => 'not a valid kind code'
  validates_inclusion_of  :status,  :in => STATUS_MAP.keys, :message => 'not a valid status code'
  attr_accessible         :summary, :description, :public, :product_id, :kind
  acts_as_classifiable
  acts_as_taggable
  acts_as_searchable      :attributes => [:summary, :description]
  after_create            :send_new_issue_alert

  # Sanitizes an untrusted hash of search parameters and prepares a conditions string suitable for passing to find(:all).
  # The calling controller should pass in the appropriate access options string to constrain the search depending on whether
  # the user is an administrator, normal or anonymous user.
  def self.prepare_search_conditions access_options, params
    params      = {} if params.nil?
    conditions  = access_options ? [access_options] : []
    conditions  << "status = #{params[:status].to_i}" unless params[:status].blank?
    conditions  << "kind = #{params[:kind].to_i}" unless params[:kind].blank?
    conditions  << "product_id = #{params[:product_id].to_i}" unless params[:product_id].blank?
    conditions  << sanitize_sql_for_conditions(["(summary LIKE '%%%s%%' OR description LIKE '%%%s%%')",
      params[:summary], params[:summary]]) unless params[:summary].blank?
    conditions.join ' AND '
  end

  # We expose this for use in the controller layer.
  def self.string_for_status status
    STATUS_MAP[status].to_s.humanize
  end

  # We expose this for use in the controller layer.
  def self.string_for_kind kind
    KIND_MAP[kind].to_s.humanize
  end

  def status_string
    Issue.string_for_status status
  end

  def kind_string
    Issue.string_for_kind kind
  end

  def visible_comments
    # can't use the Commentable association mixin methods here because we need to specify an :include clause
    conditions = { :public => true, :awaiting_moderation => false, :spam => false, :commentable_id => self.id,
      :commentable_type => 'Issue' }
    Comment.find :all, :conditions => conditions, :include => 'user', :order => 'comments.created_at'
  end

  def send_new_issue_alert
    begin
      return if self.user && self.user.superuser? # don't inform admin of his own issues
      IssueMailer.deliver_new_issue_alert self
    rescue Exception => e
      logger.error "\nerror: Issue#send_new_issue_alert for issue #{self.id} failed due to exception #{e.class}: #{e}\n\n"
    end
  end

  def self.update_timestamps_for_comment_changes?
    true
  end
end
