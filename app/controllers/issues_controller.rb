class IssuesController < ApplicationController
  before_filter     :find_product, only: :index
  before_filter     :find_issue_awaiting_moderation, only: :show
  before_filter     :prepare_issue_for_search, only: %i[index search]

  acts_as_sortable  by: %i[public kind id product_id summary status updated_at],
                    default: :updated_at,
                    descending: true

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
          @comments = @issue.comments.published # public, not awaiting moderation
          @comment = @issue.comments.new
        end
      }
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

  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  # This simplifies our search form, and allows it to "remember" search params
  # in case the user wants to modify an existing search.
  def prepare_issue_for_search
    options = params[:issue] || {}
    options[:status] = nil unless options.has_key?(:status) # suppress default
    options[:kind] = nil unless options.has_key?(:kind)     # suppress default
    @issue = Issue.new options
  end

  def find_issue_awaiting_moderation
    if conditions = default_access_options_including_awaiting_moderation
      @issue = Issue.where(conditions).find params[:id]
    else
      @issue = Issue.find params[:id]
    end
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
