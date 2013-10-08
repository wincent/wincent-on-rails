class IssuesController < ApplicationController
  before_filter     :require_admin, except: %i[create index new search show]
  before_filter     :find_product, only: :index
  before_filter     :find_issue,
                    except: %i[create destroy edit index new search show update]
  before_filter     :find_issue_awaiting_moderation, only: %i[edit show update]
  before_filter     :find_prev_next,
                    only: :show,
                    unless: -> (c) { c.request.format.try(:atom?) }
  before_filter     :prepare_issue_for_search, only: %i[index search]
  around_filter     :current_user_wrapper
  caches_page       :show,
                    if: -> (c) { c.request.format.try(:atom?) }
  cache_sweeper     :issue_sweeper, only: %i[create update destroy]
  acts_as_sortable  by: %i[public kind id product_id summary status updated_at],
                    default: :updated_at,
                    descending: true
  uses_dynamic_javascript only: :show

  def new
    # normally "kind" defaults to "bug report"
    # but check for overrides; this allows incoming links straight to "support tickets" etc
    attributes = {}
    attributes[:kind] = Issue::KIND[params[:kind].downcase.gsub(/ +/, '_').to_sym] unless params[:kind].blank?
    @issue = Issue.new attributes
  end

  def create
    @issue = Issue.new(issue_params)
    @issue.user = current_user
    @issue.awaiting_moderation = !(admin? or logged_in_and_verified?)
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

    # TODO: lots of string concatenation here; replace with relational algebra
    issues = Issue.where(options)

    # NOTE: have an N + 1 issue here (for each product we get the product info)
    # can't just :include => :product here because that will introduce an ambiguous "updated_at" column
    # thanks to acts_as_sortable (will need to update acts as sortable)
    @paginator = RestfulPaginator.new params, issues.count, issues_path

    # Rails BUG #5060: must call to_a here so that empty? will work as expected
    @issues = issues.order(sort_options).limit(@paginator.limit).
      offset(@paginator.offset).to_a

  end

  def show
    respond_to do |format|
      format.html {
        if @issue.awaiting_moderation?
          render :action => 'awaiting_moderation'
        else
          @comments = if admin?
            @issue.comments.where(:awaiting_moderation => false)
          else
            @issue.comments.published # public, not awaiting moderation
          end
          @comment = @issue.comments.new
        end
      }
      format.atom {
        @comments = @issue.comments.published # public, not awaiting moderation
      }
      format.js {
        visible = [:pending_tags, :product_id, :public, :status, :summary]
        methods = :pending_tags # not a real attribute
        render :json => @issue.to_json(:only => visible, :methods => methods)
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
        if @issue.update_attributes(issue_params)
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
          if @issue.update_attributes params[:issue], :as => role
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
      format.js
    end
  end

  def search
    if params[:issue]
      issues      = Issue.search default_access_options, params[:issue]
      @paginator  = Paginator.new params, issues.count, search_issues_path

      # to_a() call here is to work around Rails BUG #5060
      #   https://rails.lighthouseapp.com/projects/8994/tickets/5060
      @issues     = issues.limit(@paginator.limit).offset(@paginator.offset).order(sort_options).to_a
      render 'issues/search/create'
    else
      render 'issues/search/new'
    end
  end

private

  def issue_params
    permitted = %i[description kind product_id public status summary]
    permitted << :pending_tags if admin?
    params.require(:issue).permit(*permitted)
  end

  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  def find_issue
    @issue = Issue.where(default_access_options).find params[:id]
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
      @issue = Issue.where(conditions).find params[:id]
    else
      @issue = Issue.find params[:id]
    end
  end

  def find_prev_next
    # 2 additional queries here, although could try using UNION to combine them into one
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
