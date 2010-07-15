class DashboardController < ApplicationController
  before_filter :require_user
  uses_stylesheet_links

  def show
    # potentially add :awaiting_moderation => false here as well
    # (not sure, may want to actually show such items to user)
    @issues   = Issue.where(:user_id => current_user).
      limit(10).order('updated_at DESC')
    @topics   = Topic.where(:user_id => current_user).
      limit(10).order('topics.updated_at DESC').includes(:forum)
    @comments = Comment.where(:user_id => current_user).
      limit(10).order('updated_at DESC')
  end
end
