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
      # TODO: make the flash message actually true, possibly allow admin to skip confirming
      flash[:notice] = "Successfully added new email address; " \
                       "a confirmation email has been sent to #{@email.address}"
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
