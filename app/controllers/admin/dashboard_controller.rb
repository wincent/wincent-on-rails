class Admin::DashboardController < Admin::ApplicationController
  def show
    conditions     = { awaiting_moderation: true }
    @comment_count = Comment.where(conditions).count
    @issue_count   = Issue.where(conditions).count
    @topic_count   = Topic.where(conditions).count
  end
end
