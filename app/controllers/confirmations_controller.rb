class ConfirmationsController < ApplicationController
  def show
    @email        = Email.find(params[:email_id])
    @confirmation = @email.confirmations.find_by_secret(params[:id])
    if @confirmation.nil?
      flash[:error] = 'Confirmation not found.'
      redirect_to root_path
    elsif !@confirmation.completed_at.nil?
      flash[:notice] = 'Email address is already confirmed.'
      redirect_to login_path
    elsif @confirmation.cutoff < Time.now
      flash[:error] = 'Confirmation expiry date has already passed.'
      redirect_to root_path
    else
      @confirmation.update_attribute(:completed_at, Time.now)
      @email.update_attribute(:verified, true)
      @email.user.update_attribute(:verified, true)
      flash[:notice] = 'Successfully confirmed email address.'
      redirect_to login_path
    end
  end
end # class ConfirmationsController
