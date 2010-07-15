class IssuesController < ApplicationController
  before_filter     :require_admin, :except => [:create, :index, :new, :search, :show]
  before_filter     :find_product, :only => [:index]
  before_filter     :find_issue, :except => [:create, :destroy, :edit, :index, :new, :search, :show, :update]
  before_filter     :find_issue_awaiting_moderation, :only => [:edit, :show, :update]
  before_filter     :find_prev_next, :only => [:show], :unless => Proc.new { |c| c.send(:is_atom?) }
  before_filter     :prepare_issue_for_search, :only => [:index, :search]
  around_filter     :current_user_wrapper
  caches_page       :show, :if => Proc.new { |c| c.send(:is_atom?) }
  cache_sweeper     :issue_sweeper, :only => [ :create, :update, :destroy ]
  acts_as_sortable  :by => [:public, :kind, :id, :product_id, :summary, :status, :updated_at],
                    :default => :updated_at,
                    :descending => true
  uses_dynamic_javascript :only => :show
  uses_stylesheet_links

  def new
    # normally "kind" defaults to "bug report"
    # but check for overrides; this allows incoming links straight to "support tickets" etc
    attributes = {}
    attributes[:kind] = Issue::KIND[params[:kind].downcase.gsub(/ +/, '_').to_sym] unless params[:kind].blank?
    @issue = Issue.new attributes
  end

  def create
    @issue                      = Issue.new params[:issue]
    @issue.user                 = current_user
    @issue.awaiting_moderation  = !(admin? or logged_in_and_verified?)
    @issue.pending_tags         = params[:issue][:pending_tags] if admin?
    if @issue.save
      if logged_in_and_verified?
        flash[:notice] = 'Successfully created new issue'
      else
        flash[:notice] = 'Successfully submitted issue (awaiting moderation)'
      end
      redirect_to @issue
    else
      flash[:error] = 'Failed to create new issue'
      render :action => 'new'
    end
  end

  def index
    # set up options and add possible params that can be used to limit the scope of the search
    options = default_access_options # defined in ApplicationController
    add_kind_scope_condition options
    add_status_scope_condition options
    add_product_scope_condition options

    # NOTE: have an N + 1 issue here (for each product we get the product info)
    # can't just :include => :product here because that will introduce an ambiguous "updated_at" column
    # thanks to acts_as_sortable (will need to update acts as sortable)
    @paginator = RestfulPaginator.new params,
      Issue.count(:conditions => options), issues_path
    @issues = Issue.find :all, sort_options.merge({
      :offset => @paginator.offset, :limit => @paginator.limit,
      :conditions => options
    })
  end

  def show
    respond_to do |format|
      format.html {
        if @issue.awaiting_moderation?
          render :action => 'awaiting_moderation'
        else
          if admin?
            @comments = @issue.comments.find :all, :conditions => { :awaiting_moderation => false }
          else
            @comments = @issue.comments.published # public, not awaiting moderation
          end
          @comment = @issue.comments.build
        end
      }
      format.atom {
        @comments = @issue.comments.published # public, not awaiting moderation
      }
      format.js {
        require_admin do
          visible = [:pending_tags, :product_id, :public, :status, :summary]
          methods = :pending_tags # not a real attribute
          render :json => @issue.to_json(:only => visible, :methods => methods)
        end
      }
    end
  end

  # Admin only.
  def edit
    render
  end

  # Admin only.
  def update
    respond_to do |format|
      format.html {
        @issue.pending_tags = params[:issue][:pending_tags]
        if @issue.update_attributes params[:issue]
          flash[:notice] = 'Successfully updated'
          redirect_to (@issue.awaiting_moderation ? admin_issues_path : @issue)
        else
          flash[:error] = 'Update failed'
          render :action => 'edit'
        end
      }

      format.js {
        # I don't really like this special case but it seems to be the only
        # way to classify as ham without updating the record timestamp
        if params[:button] == 'ham'
          @issue.moderate_as_ham!
          render :json => {}.to_json
        else
          @issue.pending_tags = params[:issue][:pending_tags]
          if @issue.update_attributes params[:issue]
            redirect_to issue_path(@issue, :format => :js)
          else
            error = "Update failed: #{@issue.flashable_error_string}"
            render :text => error, :status => 422
          end
        end
      }
    end
  end

  # Admin only.
  def destroy
    # TODO: mark issues as deleted_at rather than really destroying them
    @issue = Issue.find params[:id]
    @issue.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Issue destroyed'
        redirect_to issues_path
      }
      format.js {
        render :json => {}.to_json
      }
    end
  end

  def search
    if params[:issue]
      issues      = Issue.search default_access_options, params[:issue]
      @paginator  = Paginator.new params, issues.count, search_issues_path

      # all() call here is to work around Rails BUG #5060
      #   https://rails.lighthouseapp.com/projects/8994/tickets/5060
      @issues     = issues.limit(@paginator.limit).offset(@paginator.offset).order(arel_sort_options).all
      render 'issues/search/create'
    else
      render 'issues/search/new'
    end
  end

private

  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  def find_issue
    @issue = Issue.find params[:id], :conditions => default_access_options
  end

  # This simplifies our search form, and allows it to "remember" search params
  # in case the user wants to modify an existing search.
  def prepare_issue_for_search
    options = params[:issue] || {}
    options[:status] = nil unless options.has_key?(:status) # suppress default
    options[:kind] = nil unless options.has_key?(:kind)     # suppress default
    @issue = Issue.new options
  end

  # model will need to know current user for annotations
  # I would prefer to pass this info down into the model explicitly, but I don't control all the
  # sites where models are created (for example, the in-place editor field plug-in)
  # http://www.zorched.net/2007/05/29/making-session-data-available-to-models-in-ruby-on-rails/
  def current_user_wrapper
    Thread.current[:current_user] = current_user
    yield
  ensure
    Thread.current[:current_user] = nil
  end

  def find_issue_awaiting_moderation
    if conditions = default_access_options_including_awaiting_moderation
      @issue = Issue.find params[:id], :conditions => conditions
    else
      @issue = Issue.find params[:id]
    end
  end

  def find_prev_next
    # 2 additonal queries here, although could try using UNION to combine them into one
    @prev   = Issue.last :conditions => default_access_options + " AND id < #{@issue.id}", :order => 'id'
    @next   = Issue.first :conditions => default_access_options + " AND id > #{@issue.id}", :order => 'id'
  end

  def add_kind_scope_condition options
    if params[:kind]
      key = params[:kind].gsub(' ', '_').downcase.to_sym
      options << " AND kind = #{Issue::KIND[key]}" if Issue::KIND.key? key
    end
  end

  def add_status_scope_condition options
    if params[:status]
      key = params[:status].gsub(' ', '_').downcase.to_sym
      options << " AND status = #{Issue::STATUS[key]}" if Issue::STATUS.key? key
    end
  end

  def add_product_scope_condition options
    options << " AND product_id = #{@product.id}" if @product
  end

  def record_not_found
    super issues_path
  end
end
