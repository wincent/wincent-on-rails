class IssuesController < ApplicationController
  before_filter     :require_admin, :except => [:create, :index, :new, :search, :show]
  before_filter     :find_product, :only => [:index]
  before_filter     :find_issue, :except => [:create, :destroy, :edit, :index, :new, :search, :show, :update]
  before_filter     :find_issue_awaiting_moderation, :only => [:edit, :show, :update]
  before_filter     :find_prev_next, :only => [:show]

  # NOTE: as of Rails 2.1 this filter will change
  # see: http://github.com/rails/rails/commit/14a40804a29a57ad05ca6bffbe1e5334089593a9
  # see: http://github.com/rails/rails/commit/7708650f73ddb4db300ea2059c60c1d907a4384e
  after_filter      :cache_show_feed, :only => [ :show ]
  cache_sweeper     :issue_sweeper, :only => [ :create, :update, :destroy ]
  in_place_edit_for :issue, :summary
  acts_as_sortable  :by => [:public, :kind, :id, :product_id, :summary, :status, :updated_at],
                    :default => :updated_at,
                    :descending => true

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
    if @issue.save
      if logged_in_and_verified?
        flash[:notice] = 'Successfully created new issue.'
      else
        flash[:notice] = 'Successfully submitted issue (awaiting moderation).'
      end
      redirect_to issue_path(@issue)
    else
      flash[:error] = 'Failed to create new issue.'
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
    @paginator = Paginator.new params, Issue.count(:conditions => options), issues_path
    @issues = Issue.find :all,
      sort_options.merge({ :offset => @paginator.offset, :limit => @paginator.limit, :conditions => options })
    @search = Issue.new
  end

  def show
    respond_to do |format|
      format.html {
        if @issue.awaiting_moderation?
          render :action => 'awaiting_moderation'
        else
          if admin?
            @comments = @issue.comments.find :all, :conditions => { :awaiting_moderation => false, :spam => false }
          else
            @comments = @issue.visible_comments # public, not awaiting moderation, not spam
          end
          @comment = @issue.comments.build
        end
      }
      format.atom {
        @comments = @issue.visible_comments # public, not awaiting moderation, not spam
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
        if @issue.update_attributes params[:issue]
          flash[:notice] = 'Successfully updated'
          redirect_to (@issue.awaiting_moderation ? admin_issues_path : issue_path(@issue))
        else
          flash[:error] = 'Update failed'
          render :action => 'edit'
        end
      }
      format.js {
        if params[:button] == 'spam'
          @issue.moderate_as_spam!
          render :update do |page|
            page.visual_effect :fade, "issue_#{@issue.id}"
          end
        elsif params[:button] == 'ham'
          @issue.moderate_as_ham!
          render :update do |page|
            page.visual_effect :highlight, "issue_#{@issue.id}", :duration => 1.5
            page.visual_effect :fade, "issue_#{@issue.id}_ham_form"
            page.visual_effect :fade, "issue_#{@issue.id}_spam_form"
          end
        else
          raise 'unrecognized AJAX action'
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
        render :update do |page|
          page.visual_effect :fade, "issue_#{@issue.id}"
        end
      }
    end
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

  def search
    conditions  = Issue.prepare_search_conditions default_access_options, params[:issue]
    @paginator  = Paginator.new params, Issue.count(:conditions => conditions), search_issues_path
    @issues     = Issue.find :all,
      sort_options.merge({ :conditions => conditions, :offset => @paginator.offset, :limit => @paginator.limit })
  end

private

  # If this is an AJAX request tries to save the model and returns a 200 status code on success, 422 on failure.
  def handle_ajax_request
    respond_to do |format|
      format.js { render :text => '', :status => (@issue.save ? 200 : 422) }
    end
  end

  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  def find_issue
    @issue = Issue.find params[:id], :conditions => default_access_options
  end

  def find_issue_awaiting_moderation
    @issue = Issue.find params[:id], :conditions => default_access_options_including_awaiting_moderation
  end

  def find_prev_next
    # 2 additonal queries here, although could try using UNION to combine them into one
    @prev   = Issue.find :first, :conditions => default_access_options + " AND id < #{@issue.id}", :order => 'id DESC'
    @next   = Issue.find :first, :conditions => default_access_options + " AND id > #{@issue.id}", :order => 'id ASC'
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

  def cache_show_feed
    cache_page if params[:format] == 'atom'
  end

  def record_not_found
    super issues_path
  end
end
