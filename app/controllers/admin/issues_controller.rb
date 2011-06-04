class Admin::IssuesController < Admin::ApplicationController
  # TODO: compact interface for mass-deleting spam issues using checkboxes
  def index
    issues      = Issue.where :awaiting_moderation => true
    @paginator  = Paginator.new params, issues.count, admin_issues_path, 20
    @issues     = issues.order('created_at DESC').limit(@paginator.limit).
      offset(@paginator.offset)
  end
end
