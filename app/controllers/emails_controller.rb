class EmailsController < ApplicationController
  before_filter :require_admin
  before_filter :get_user_and_email

  def edit
    render
  end

  def update
    if @email.update_attributes params[:email]
      flash[:notice] = 'Successfully updated'
      redirect_to @user
      # TODO: implement the #show action so we can do this instead:
      #redirect_to [@email, @user]
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

private

  def get_user_and_email
    @user   = User.find_with_param! params[:user_id]
    @email  = @user.emails.find_by_address!(params[:id])
  end
end
