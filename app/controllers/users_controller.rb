class UsersController < ApplicationController
  before_filter     :require_user, :only => [ :edit, :update ]
  before_filter     :require_admin, :only => [ :index ]
  before_filter     :get_user, :only => [ :edit, :show, :update ]
  before_filter     :require_edit_privileges, :only => [ :edit, :update ]
  acts_as_sortable  :by => [:id, :display_name, :login_name, :created_at]

  def index
    @users = User.includes :emails
  end

  def new
    @user   = User.new
    @email  = @user.emails.new
  end

  def create
    User.transaction do
      @user = User.new params[:user]
      @user.save!
      @email = @user.emails.create :address => @user.email
      @email.save!
    end
    confirmation  = @email.confirmations.create
    deliver ConfirmationMailer.confirmation_message(confirmation)
    set_current_user @user if !logged_in? # auto-log in
    redirect_to dashboard_path
  rescue ActiveRecord::RecordInvalid
    @user.valid? # re-run validations to pick up errors in email association
    flash[:error] = 'Failed to create new account'
    render :action => 'new'
  end

  def show
    render
  end

  def edit
    render
  end

  def update
    if @user.update_attributes params[:user]
      flash[:notice] = 'Successfully updated'
      redirect_to @user
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def can_edit?
    admin? or (logged_in? and @user.id == self.current_user.id)
  end

  def require_edit_privileges
    unless can_edit?
      flash[:notice] = 'You are not allowed to edit this user'
      redirect_to @user
    end
  end

  def get_user
    @user = User.find_with_param! params[:id]
  end
end
