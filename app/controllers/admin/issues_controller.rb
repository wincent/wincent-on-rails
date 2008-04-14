class Admin::IssuesController < ApplicationController
  before_filter :require_admin

  def index
    @paginator  = Paginator.new params, Issue.count(:conditions => { :awaiting_moderation => true }), admin_issues_path
    @issues     = Issue.find :all, :offset => @paginator.offset, :conditions => { :awaiting_moderation => true },
      :order => 'created_at DESC'
  end

  # AJAX (format: js) only.
  def update
    @issue = Issue.find params[:id]
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
  end
end
