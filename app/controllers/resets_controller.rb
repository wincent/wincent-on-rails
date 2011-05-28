class ResetsController < ApplicationController
  before_filter :find_reset_and_user, :only => [ :edit, :update ]

  def new
    @reset = Reset.new
  end

  def create
    address = params[:reset][:email_address]
    if email = Email.where(:deleted_at => nil).find_by_address(address)
      if email.resets.where('created_at > ?', 3.days.ago).count > 5
        flash[:error] = 'You have exceeded the resets limit for this email address for today; please try again later'
      else
        deliver ResetMailer.reset_message(email.resets.create)
      end
      redirect_to login_path
    else
      @reset = Reset.new
      flash[:error] = 'Invalid email address'
      render :action => 'new'
    end
  end

  def show
    redirect_to :action => 'edit'
  end

  def edit
    if @reset.nil?
      flash[:error] = 'Reset token not found'
      redirect_to root_path
    elsif !@reset.completed_at.nil?
      flash[:notice] = 'Reset token already used'
      redirect_to login_path
    elsif @reset.cutoff < Time.now
      flash[:error] = 'Reset token expiry date has already passed'
      redirect_to root_path
    else # success!
      render
    end
  end

  def update
    raise ActiveRecord::RecordNotFound if @reset.nil? # likely attack, so no need for a friendly flash
    if @reset.update_attributes params[:reset]
      @user.passphrase              = params[:passphrase]
      @user.passphrase_confirmation = params[:passphrase_confirmation]
      @user.resetting_passphrase    = true
      if @user.save
        @reset.update_attribute(:completed_at, Time.now)
        flash[:notice] = 'Successfully updated passphrase'
        self.current_user = @user # auto-log in
        redirect_to dashboard_path
        return
      end
    end

    # reset or user not valid, try again
    render :action => 'edit'
  end

private

  def find_reset_and_user
    @reset = Reset.includes(:email).find_by_secret params[:id]
    @user = @reset ? @reset.email.user : nil
  end
end # class ResetsController
