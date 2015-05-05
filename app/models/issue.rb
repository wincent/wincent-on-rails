class Issue < ActiveRecord::Base
  # NOTE: We used to use "new" (0) as a separate status, but simplified it away.
  STATUS      = Hash.new(0).merge!(open: 1, closed: 2).freeze
  STATUS_MAP  = STATUS.invert.freeze
  KIND        = Hash.new(0).merge!(bug: 0, feature_request: 1, support_ticket: 2, feedback: 3).freeze
  KIND_MAP    = KIND.invert.freeze

  belongs_to              :user
  belongs_to              :last_commenter, class_name: 'User'
  belongs_to              :product
  has_many                :comments,
                          -> { includes(:user).order('comments.created_at') },
                          as:         :commentable,
                          extend:     Commentable,
                          dependent:  :destroy
  has_many                :monitorships, as: :monitorable, dependent: :destroy
  validates_presence_of   :summary
  validates_length_of     :description, maximum: 128 * 1024
  validates_inclusion_of  :kind,    in: KIND_MAP.keys,   message: 'not a valid kind code'
  validates_inclusion_of  :status,  in: STATUS_MAP.keys, message: 'not a valid status code'

  attr_accessible :summary, :description, :public, :product_id, :kind, :status, :pending_tags

  acts_as_classifiable
  acts_as_taggable
  acts_as_searchable      attributes: [:summary, :description]

  # Takes un untrusted hash of search parameters and constructs an
  # ActiveRelation query. The calling controller should pass in the appropriate
  # access options to constrain the search depending on whether the user is an
  # administrator, normal or anonymous user.
  def self.search access_options, params = {}
    finder = Issue.where access_options
    finder = finder.where(status: params[:status]) unless params[:status].blank?
    finder = finder.where(kind: params[:kind]) unless params[:kind].blank?
    finder = finder.where(product_id: params[:product_id]) unless params[:product_id].blank?

    unless params[:summary].blank?
      t = finder.arel_table
      like = "%#{params[:summary]}%" # TODO[fixme]: user here can pass '%', not that it matters
      finder = finder.where(t[:summary].matches(like).or(t[:description].matches(like)))
    end
    finder
  end

  # We expose this for use in other layers (helpers, observers).
  def self.string_for_status status
    STATUS_MAP[status].to_s.gsub('_', ' ')
  end

  # We expose this for use in other layers (helpers, observers).
  def self.string_for_kind kind
    KIND_MAP[kind].to_s.gsub('_', ' ')
  end

  def status_string
    Issue.string_for_status status
  end

  def kind_string
    Issue.string_for_kind kind
  end

  def closed?
    status == STATUS[:closed]
  end

  def self.update_timestamps_for_comment_changes?
    true
  end
end
