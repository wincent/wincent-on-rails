class IssuesController < ApplicationController
  before_filter :find_product, only: :index
  before_filter :find_issue_awaiting_moderation, only: :show
  before_filter :flash_deprecation_notice

  def index
    options = default_access_options # defined in ApplicationController
    issues = Issue.where(options)

    @paginator = RestfulPaginator.new params, issues.count, issues_path

    # Rails BUG #5060: must call to_a here so that empty? will work as expected
    @issues = issues.order('id DESC').limit(@paginator.limit).
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

private

  def flash_deprecation_notice
    flash.now[:notice] =
      'You are viewing an historical archive of past issues. ' +
      'Please report new issues to the appropriate project issue tracker on ' +
      '<a href="https://github.com/wincent?tab=repositories">GitHub</a>.'
  end

  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  def find_issue_awaiting_moderation
    if conditions = default_access_options_including_awaiting_moderation
      @issue = Issue.where(conditions).find params[:id]
    else
      @issue = Issue.find params[:id]
    end
  end

  def record_not_found
    super issues_path
  end
end
