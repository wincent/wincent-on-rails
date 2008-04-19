class ResetsController < ApplicationController
  before_filter :find_reset_and_user, :only => [ :edit, :update ]

  def new
    @reset = Reset.new
  end

  def create
    address = params[:reset][:email_address]
    if @user = User.find_by_email(address)
      # TODO: rate-limit resets to prevent abuse
      reset     = @user.resets.create
      error_msg = "An error occurred while sending the email to #{address}"
      begin
        ResetMailer.deliver_reset_message reset
      rescue Net::SMTPFatalError
        flash[:error] = "#{error_msg} (this looks like a permanent delivery problem; please check the address)"
      rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError
        flash[:error] = "#{error_msg} (this looks like a temporary delivery problem; you may want to try again later)"
      rescue Exception
        flash[:error] = "#{error_msg} (the cause of the error was unknown)"
      else
        flash[:notice] = "Please check your mail: an email has been sent to #{address}."
      end
      redirect_to login_path
    else
      @reset = Reset.new
      flash[:error] = 'Invalid email address.'
      render :action => 'new'
    end
  end

  def edit
    if @reset.nil?
      flash[:error] = 'Reset token not found.'
      redirect_to root_path
    elsif !@reset.completed_at.nil?
      flash[:notice] = 'Reset token already used.'
      redirect_to login_path
    elsif @reset.cutoff < Time.now
      flash[:error] = 'Reset token expiry date has already passed.'
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
        flash[:notice] = 'Successfully updated passphrase.'
        self.current_user = @user # auto-log in
        redirect_to user_path(@user)
        return
      end
    end

    # reset or user not valid, try again
    render :action => 'edit'
  end

private

  def find_reset_and_user
    @reset = Reset.find_by_secret params[:id], :include => :user
    @user = @reset ? @reset.user : nil
  end

end # class ResetsController
