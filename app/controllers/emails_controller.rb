class EmailsController < ApplicationController
  before_filter :require_admin, :except => [:new, :create, :show]
  before_filter :get_user
  before_filter :get_email, :only => [:edit, :show, :update]

  def new
    @email = @user.emails.new
  end

  def create
    @email = @user.emails.new params[:email]
    if @email.save
      confirmation  = @email.confirmations.create
      deliver ConfirmationMailer.confirmation_message(confirmation)
      redirect_to [@user, @email]
    else
      flash[:error] = 'Failed to add new email address'
      render :action => :new
    end
  end

  def show
    render
  end

  def edit
    render
  end

  def update
    # TODO: review and see whether this should be accessible
    # (we already have other attributes which are and probably
    # should not be; eg. verified)
    @email.default = params[:email].delete(:default)

    if @email.update_attributes params[:email]
      flash[:notice] = 'Successfully updated'
      redirect_to [@user, @email]
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

private

  def get_user
    @user = User.find_with_param! params[:user_id]
  end

  def get_email
    @email = @user.emails.find_by_address!(params[:id])
  end
end
