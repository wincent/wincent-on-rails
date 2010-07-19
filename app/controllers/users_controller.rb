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
    @email  = @user.emails.build
  end

  def create
    @user = User.new params[:user]
    @email = @user.emails.build :address => @user.email
    if @user.save
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

  def update
    # BUG: no constraints yet to prevent user "deleting" all their emails
    # will have a race but still better than no check at all
    @email = @user.update_emails :add => params[:user][:email], :delete => params[:delete_email]
    if @user.update_attributes params[:user]
      base_msg = 'Successfully updated'
      if @email
        confirm_email_and_redirect(base_msg)
      else
        flash[:notice] = base_msg
        redirect_to @user
      end
    else
      # if user deletes emails but also has validation errors,
      # they will still see the emails when the form is reloaded, so get emails again
      get_emails
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def confirm_email_and_redirect base_msg
    confirmation  = @email.confirmations.create
    deliver ConfirmationMailer.confirmation_message(confirmation)
    self.current_user = @user if !admin? or !logged_in? # auto-log in
    redirect_to @user
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
