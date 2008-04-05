class ConfirmationsController < ApplicationController
  before_filter :require_user, :only => [ :new, :create ]

  def new
    @confirmation = Confirmation.new
  end

  def create
    emails  = current_user.emails.find_all_by_verified :false
    errors  = []
    notices = []
    emails.each do |e|
      if params[:emails][e.id.to_s] == '1'
        error_msg     = "An error occurred while sending the confirmation email to #{e.address}"
        confirmation  = e.confirmations.create
        begin
          ConfirmationMailer.deliver_confirmation_message confirmation, request
        rescue Net::SMTPFatalError
          errors << "#{error_msg} (this looks like a permanent delivery problem; please check the address)"
        rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError
          errors << "#{error_msg} (this looks like a temporary delivery problem; you may want to try again later)"
        rescue Exception
          errors << "#{error_msg} (the cause of the error was unknown)"
        else
          notices << "A confirmation email has been sent to #{e.address}"
        end
      end
    end
    flash[:error] = errors.join('; ') if !errors.empty?
    flash[:notice]  = notices.join('; ') if !notices.empty?
    redirect_to user_path(current_user)
  end

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
      redirect_to root_path # redirect here to conf#new
    else
      @confirmation.update_attribute :completed_at, Time.now
      @confirmation.email.update_attribute :verified, true
      @confirmation.email.user.update_attribute :verified, true
      flash[:notice] = 'Successfully confirmed email address.'
      redirect_to (logged_in? ? root_path : login_path) # don't autologin in case this is a brute force attack
    end
  end
end # class ConfirmationsController
