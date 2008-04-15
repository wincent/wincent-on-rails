class Admin::DashboardController < ApplicationController
  before_filter     :require_admin

  def show
    conditions      = 'awaiting_moderation = TRUE'
    @comment_count  = Comment.count :conditions => conditions
    @issue_count    = Issue.count   :conditions => conditions
    @topic_count    = Topic.count   :conditions => conditions
  end
end
