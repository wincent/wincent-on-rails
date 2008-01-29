class UsersController < ApplicationController
  # TODO: restrict edit access to logged in user, same user as wants to edit
  #before_filter :require_admin, :only => [ :destroy ]
  before_filter :require_user, :only => [ :index ]

  def index
    @users = User.find(:all)
  end
end
