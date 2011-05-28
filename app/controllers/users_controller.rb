class UsersController < ApplicationController
  before_filter     :require_user, :only => [ :edit, :update ]
  before_filter     :require_admin, :only => [ :index ]
  before_filter     :get_user, :only => [ :edit, :show, :update ]
  before_filter     :get_emails, :only => [ :edit ]
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
    @user = User.new params[:user]
    if @user.save
      @email = @user.emails.create :address => @user.email
      confirm_email_and_redirect 'Successfully created new account'
    else
      flash[:error] = 'Failed to create new account'
      render :action => 'new'
    end
  end

  def show
    render
  end

  def edit
    render
  end

  # TODO: refactor this method, split off email stuff into a separate controller
  def update
    if @user.update_attributes params[:user]
      base_msg = 'Successfully updated'
      if !params[:user][:email].blank?
        if @email = @user.emails.create(:address => params[:user][:email])
          confirm_email_and_redirect(base_msg)
        else
          get_emails
          flash[:error] = 'Update failed'
          render :action => 'edit'
        end
      else
        flash[:notice] = base_msg
        redirect_to @user
      end
    else
      get_emails # going to render @emails
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def confirm_email_and_redirect base_msg
    confirmation  = @email.confirmations.create
    deliver ConfirmationMailer.confirmation_message(confirmation)
    set_current_user @user if !logged_in? # auto-log in
    redirect_to dashboard_path
  end

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

  def get_emails
    @emails = @user.emails.where(:deleted_at => nil)
  end
end
