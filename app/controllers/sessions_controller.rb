class SessionsController < ApplicationController
  def new
    render
  end

  # TODO: OpenID support
  def create
    unless session.blank?
      old_session = session.to_hash
      reset_session
      old_session.each { |key, value| session[key.to_sym] = value }
    end
    if self.set_current_user = User.authenticate(params[:email], params[:passphrase])
      flash[:notice] = 'Successfully logged in'
      original_uri = session[:original_uri] || params[:original_uri]
      if original_uri.blank?
        redirect_to dashboard_path
      else
        session[:original_uri] = nil
        redirect_to original_uri
      end
    else
      flash[:error] = 'Invalid email or passphrase'
      render :action => 'new'
    end
  end

  def destroy
    if self.logged_in?
      reset_session unless session.blank?
      self.current_user = nil # delete some info from the cookies, invalidate the session key in the database
      flash[:notice] = 'You have logged out successfully'
    else
      flash[:error] = "Can't log out (weren't logged in)"
    end
    redirect_to root_path
  end
end
