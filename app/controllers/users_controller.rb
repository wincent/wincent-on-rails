class UsersController < ApplicationController
  before_filter     :require_user, :only => [ :edit, :update ]
  before_filter     :require_verified, :only => [ :index ]
  before_filter     :get_user, :only => [ :edit, :show, :update ]
  before_filter     :get_emails, :only => [ :edit ]
  before_filter     :require_edit_privileges, :only => [ :edit, :update ]
  acts_as_sortable  :by => [:id, :display_name, :login_name, :created_at]

  def index
    @users = User.find :all, :include => :emails
  end

  def new
    @user   = User.new
    @email  = @user.emails.build
  end

  def create
    @user = User.new(params[:user])
    @email = @user.emails.build(:address => @user.email)
    if @user.save
      confirm_email_and_redirect 'Successfully created new account'
    else
      flash[:error] = 'Failed to create new account.'
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
    # NOTE: no constraints yet to prevent user "deleting" all their emails
    @email = @user.update_emails :add => params[:user][:email], :delete => params[:delete_email]
    if @user.update_attributes params[:user]
      base_msg = 'Successfully updated'
      if @email
        confirm_email_and_redirect(base_msg)
      else
        flash[:notice] = base_msg
        redirect_to user_path(@user)
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
    error_msg     = "but an error occurred while sending the confirmation email to #{@email.address}"
    confirmation  = @email.confirmations.create
    begin
      ConfirmationMailer.deliver_confirmation_message confirmation
    rescue Net::SMTPFatalError
      flash[:error] = "#{base_msg} #{error_msg} (this looks like a permanent delivery problem; please check the address)"
    rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError
      flash[:error] = "#{base_msg} #{error_msg} (this looks like a temporary delivery problem; you may want to try again later)"
    rescue Exception
      flash[:error] = "#{base_msg} #{error_msg} (the cause of the error was unknown)"
    else
      flash[:notice] = "#{base_msg}: a confirmation email has been sent to #{@email.address}."
    end
    self.current_user = @user if !admin? or !logged_in? # auto-log in
    redirect_to user_path(@user)
  end

  def can_edit?
    admin? or (logged_in? and @user.id == self.current_user.id)
  end

  def require_edit_privileges
    unless can_edit?
      flash[:notice] = 'You are not allowed to edit this user'
      redirect_to user_path(@user)
    end
  end

  def get_user
    @user = User.find_with_param! params[:id]
  end

  def get_emails
    @emails = @user.emails.find(:all, :conditions => 'deleted_at IS NULL')
  end
end
