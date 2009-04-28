class Admin::IssuesController < ApplicationController
  before_filter :require_admin

  # TODO: compact interface for mass-deleting spam issues using checkboxes
  def index
    @paginator  = Paginator.new params,
      Issue.count(:conditions => { :awaiting_moderation => true }),
      admin_issues_path, 20
    @issues     = Issue.find :all, :offset => @paginator.offset,
      :conditions => { :awaiting_moderation => true },
      :order => 'created_at DESC', :limit => @paginator.limit
  end
end
