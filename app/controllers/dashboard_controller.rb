class DashboardController < ApplicationController
  before_filter :require_user

  def show
    # potentially add :awaiting_moderation => false here as well
    # (not sure, may want to actually show such items to user)
    @issues   = Issue.where(:user_id => current_user).
      limit(10).order('updated_at DESC')
    @comments = Comment.where(:user_id => current_user).
      limit(10).order('updated_at DESC')
  end
end
