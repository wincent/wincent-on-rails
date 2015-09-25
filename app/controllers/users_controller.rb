class UsersController < ApplicationController
  before_filter     :require_admin, only: :index
  before_filter     :get_user, only: :show
  acts_as_sortable  :by => [:id, :display_name, :login_name, :created_at]

  def index
    @users = User.includes :emails
  end

  def show
    render
  end

private

  def get_user
    @user = User.find_with_param! params[:id]
  end
end
