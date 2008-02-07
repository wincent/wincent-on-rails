class CommentsController < ApplicationController
  before_filter :require_user, :only => [ :index ]

  def index
    if admin?         # admins can see all comments
      @comments = Comment.find(:all)
    else              # all other in users can only see their own
      @comments = Comment.find_by_user_id(current_user.id)
    end
  end

  def show
    render
  end
end
