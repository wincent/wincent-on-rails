class UsersController < ApplicationController
  before_filter     :require_user, :only => [ :edit, :update ]
  before_filter     :require_verified, :only => [ :index ]
  before_filter     :get_user, :only => [ :edit, :show ]
  acts_as_sortable  :by => [:id, :display_name, :login_name, :created_at]

  def index
    @users = User.find(:all)
  end

  def new
    @user   = User.new
    @email  = @user.emails.build
  end

  def create
    @user = User.new(params[:user])
    @email = @user.emails.build(:address => @user.email)
    if @user.save
      base_msg      = 'Successfully created new account'
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
      self.current_user = @user if not admin?
      redirect_to user_path(@user)
    else
      flash[:error] = 'Failed to create new account.'
      render :action => 'new'
    end
  end

  def show
    render
  end

  def edit
    unless admin? or (logged_in? and @user.id == self.current_user.id)
      redirect_to user_path(@user)
    else
      render
    end
  end

  def update

  end

private

  def get_user
    @user = User.find_with_param! params[:id]
  end

end
