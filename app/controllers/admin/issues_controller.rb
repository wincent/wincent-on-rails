class Admin::IssuesController < ApplicationController
  before_filter :require_admin

  # TODO: compact interface for mass-deleting spam issues using checkboxes
  def index
    @paginator  = Paginator.new params, Issue.count(:conditions => { :awaiting_moderation => true }), admin_issues_url, 20
    @issues     = Issue.find :all, :offset => @paginator.offset, :conditions => { :awaiting_moderation => true },
      :order => 'created_at DESC', :limit => @paginator.limit
  end

  # AJAX (format: js) only.
  def update
    @issue = Issue.find params[:id]
    if params[:button] == 'ham'
      @issue.moderate_as_ham!
      render :update do |page|
        page.visual_effect :highlight, "issue_#{@issue.id}", :duration => 1.5
        page.visual_effect :fade, "issue_#{@issue.id}_ham_form"
      end
    else
      raise 'unrecognized AJAX action'
    end
  end
end
