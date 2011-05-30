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
  validates_length_of     :description, :maximum => 128 * 1024
  validates_inclusion_of  :kind,    :in => KIND_MAP.keys,   :message => 'not a valid kind code'
  validates_inclusion_of  :status,  :in => STATUS_MAP.keys, :message => 'not a valid status code'
  attr_accessible         :summary, :description, :public, :product_id, :kind,
    :status
  acts_as_classifiable
  acts_as_taggable
  acts_as_searchable      :attributes => [:summary, :description]
  set_callback            :save, :before, :prepare_annotation
  set_callback            :save, :after, :annotate

  # Takes un untrusted hash of search parameters and constructs an
  # ActiveRelation query. The calling controller should pass in the appropriate
  # access options to constrain the search depending on whether the user is an
  # administrator, normal or anonymous user.
  def self.search access_options, params = {}
    finder = Issue.where access_options
    finder = finder.where(:status => params[:status]) unless params[:status].blank?
    finder = finder.where(:kind => params[:kind]) unless params[:kind].blank?
    finder = finder.where(:product_id => params[:product_id]) unless params[:product_id].blank?

    unless params[:summary].blank?
      t = finder.arel_table
      like = "%#{params[:summary]}%"
      finder = finder.where(t[:summary].matches(like).or(t[:description].matches(like)))
    end
    finder
  end

  # We expose this for use in the controller layer.
  def self.string_for_status status
    STATUS_MAP[status].to_s.gsub('_', ' ')
  end

  # We expose this for use in the controller layer.
  def self.string_for_kind kind
    KIND_MAP[kind].to_s.gsub('_', ' ')
  end

  def status_string
    Issue.string_for_status status
  end

  def kind_string
    Issue.string_for_kind kind
  end

  def prepare_annotation
    @annotations = []
    return if new_record?
    changes.each do |change|
      field, from, to = change[0], change[1][0], change[1][1]
      case field
      when 'summary'
        @annotations << format_annotation('Summary', from, to)
      when 'kind'
        @annotations << format_annotation('Kind', Issue::string_for_kind(from), kind_string)
      when 'public'
        @annotations << format_annotation('Public', from, to)
      when 'status'
        @annotations << format_annotation('Status', Issue::string_for_status(from), status_string)
      when 'product_id'
        if from and to
          products  = Product.find(from, to)
          from      = products.find {|p| p.id == from }.name
          to        = products.find {|p| p.id == to }.name
        elsif from
          from, to  = Product.find(from).name, 'none'
        elsif to
          from, to  = 'none', Product.find(to).name
        else # should never get here
          from, to  = 'none', 'none'
        end
        @annotations << format_annotation('Product', from, to)
      end
    end
    if pending_tags?
      from = tag_names.join(' ')
      to = pending_tags
      @annotations << format_annotation('Tags', from, to) if from != to
    end
  end

  def annotate
    return if @annotations.empty?
    comment = comments.new(:body => @annotations.join("\n"))
    user = Thread.current[:current_user]
    comment.user_id = user.id if user
    comment.awaiting_moderation = !(user && user.superuser?)
    comment.save
  end

  # Formats an annotation for a single field using appropriate wikitext markup.
  def format_annotation field, from, to
    <<ANNOTATION
'''#{field}''' changed:

* '''From:''' #{from}
* '''To:''' #{to}
ANNOTATION
  end

  def self.update_timestamps_for_comment_changes?
    true
  end
end
