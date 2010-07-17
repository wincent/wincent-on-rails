class ConfirmationsController < ApplicationController
  before_filter :require_user, :only => [ :new, :create ]

  def new
    @confirmation = Confirmation.new
  end

  def create
    emails  = current_user.emails.where(:verified => false)
    emails.each do |e|
      if params[:emails][e.id.to_s] == '1'
        deliver ConfirmationMailer.confirmation_message(e.confirmations.create)
      end
    end
    redirect_to current_user
  end

  def show
    @confirmation = Confirmation.includes(:email).find_by_secret params[:id]
    if @confirmation.nil?
      flash[:error] = 'Confirmation not found'
      redirect_to root_path
    elsif !@confirmation.completed_at.nil?
      flash[:notice] = 'Email address is already confirmed'
      redirect_to login_path
    elsif @confirmation.cutoff < Time.now
      flash[:error] = 'Confirmation expiry date has already passed'
      redirect_to root_path # redirect here to conf#new
    else
      @confirmation.update_attribute :completed_at, Time.now
      @confirmation.email.update_attribute :verified, true
      @confirmation.email.user.update_attribute :verified, true
      flash[:notice] = 'Successfully confirmed email address'
      redirect_to dashboard_path
    end
  end

protected

  def deliver mail
    begin
      flash[:error] = [] if flash[:error].blank?
      flash[:notice] = [] if flash[:notice].blank?
      recipient = mail.to.first
      error_msg = "An error occurred while sending the confirmation email to #{recipient}"
      mail.deliver
    rescue Net::SMTPFatalError
      flash[:error] << "#{error_msg} (this looks like a permanent delivery problem; please check the address)"
    rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError
      flash[:error] << "#{error_msg} (this looks like a temporary delivery problem; you may want to try again later)"
    rescue Exception
      flash[:error] << "#{error_msg} (the cause of the error was unknown)"
    else
      flash[:notice] << "A confirmation email has been sent to #{recipient}"
    end
  end
end # class ConfirmationsController
