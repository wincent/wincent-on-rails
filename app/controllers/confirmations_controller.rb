class ConfirmationsController < ApplicationController
  def show
    @confirmation = Confirmation.find_by_secret params[:id], :include => :email
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
      @confirmation.update_attribute :completed_at, Time.now
      @confirmation.email.update_attribute :verified, true
      @confirmation.email.user.update_attribute :verified, true
      flash[:notice] = 'Successfully confirmed email address.'
      redirect_to login_path # don't autologin in case this is a brute force attack
    end
  end
end # class ConfirmationsController
