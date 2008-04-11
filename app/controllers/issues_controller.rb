class IssuesController < ApplicationController
  # TODO: before deployment uncomment this next line
  # some issues are sensitive and I want an opportunity to mark them as private before going live
  #before_filter     :require_admin
  before_filter     :require_admin, :except => [:create, :index, :new, :show]
  before_filter     :find_product, :only => [:index]
  before_filter     :find_issue, :except => [:create, :index, :new]
  acts_as_sortable  :by => [:kind, :id, :product_id, :summary, :status, :updated_at], :default => :updated_at, :descending => true

  def new
    @issue = Issue.new
  end

  def create
    @issue                      = Issue.new params[:issue]
    @issue.user                 = current_user
    @issue.awaiting_moderation  = !(admin? or logged_in_and_verified?)
    if @issue.save
      if logged_in_and_verified?
        flash[:notice] = 'Successfully created new issue.'
        redirect_to issue_path(@issue)
      else
        # TODO: admin interface for inspecting/moderating
        flash[:notice] = 'Successfully submitted issue (awaiting moderation).'
        redirect_to issues_path
      end
    else
      flash[:error] = 'Failed to create new issue.'
      render :action => 'new'
    end
  end

  def index
    options = default_access_options

    # possible params that can be used to limit the scope of the search
    add_kind_scope_condition options
    add_status_scope_condition options
    options[:product_id]  = @product if @product

    @paginator  = Paginator.new params, Issue.count(:conditions => options), issues_path

    # NOTE: have an N + 1 issue here (for each product we get the product info)
    # can't just :include => :product here because that will introduce an ambiguous "updated_at" column
    # thanks to acts_as_sortable (will need to update acts as sortable)
    @issues     = Issue.find :all, sort_options.merge({ :offset => @paginator.offset, :limit => @paginator.limit, :conditions => options })
  end

  def show
    if admin?
      @comments = @issue.comments.find :all, :conditions => { :spam => false }
    else
      @comments = @issue.visible_comments # public, not awaiting moderation, not spam
    end
    @comment = @issue.comments.build
  end

  # AJAX method, admin only.
  def update_product_id
    if params[:product_id] == '' # special case: user selected the blank (no product) from the pop-up
      @issue.product = nil
    else
      @issue.product = Product.find(params[:product_id])
    end
    handle_ajax_request
  end

  # AJAX method, admin only.
  def update_kind
    @issue.kind = params[:kind]
    handle_ajax_request
  end

  # AJAX method, admin only.
  def update_status
    @issue.status = params[:status]
    handle_ajax_request
  end

  # AJAX method, admin only.
  def update_public
    @issue.public = params[:public]
    handle_ajax_request
  end

private

  # If this is an AJAX request tries to save the model and returns a 200 status code on success, 422 on failure.
  def handle_ajax_request
    respond_to do |format|
      format.js { render :text => '', :status => (@issue.save ? 200 : 422) }
    end
  end

  def default_access_options
    if admin?
      { :awaiting_moderation => false, :spam => false }
    elsif logged_in?
      ['awaiting_moderation = FALSE AND spam = FALSE AND (public = TRUE OR user_id = ?)', current_user]
    else
      { :awaiting_moderation => false, :spam => false, :public => true }
    end
  end

  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  def find_issue
    @issue = Issue.find params[:id], :conditions => default_access_options
  end

  def add_kind_scope_condition options
    if params[:kind]
      key = params[:kind].gsub(' ', '_').downcase.to_sym
      options[:kind] = Issue::KIND[key] if Issue::KIND.key? key
    end
  end

  def add_status_scope_condition options
    if params[:status]
      key = params[:status].gsub(' ', '_').downcase.to_sym
      options[:status] = Issue::STATUS[key] if Issue::STATUS.key? key
    end
  end

  def record_not_found
    super issues_path
  end
end
