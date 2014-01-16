class SessionsController < ApplicationController
  def new
    @session = Session.new(original_uri: params[:original_uri])
  end

  def create
    old_session = session.to_hash
    reset_session
    old_session.each { |key, value| session[key.to_sym] = value }
    @session = Session.new(params[:session])

    if user = @session.user
      set_current_user(user)
      flash[:notice] = 'Successfully logged in'
      original_uri = @session.original_uri || session[:original_uri]
      if original_uri.blank?
        redirect_to dashboard_path
      else
        session[:original_uri] = nil
        redirect_to original_uri
      end
    else
      flash[:error] = 'Invalid email or passphrase'
      render action: 'new'
    end
  end

  def destroy
    if logged_in?
      reset_session
      set_current_user nil # cookie cleanup and session invalidation in db
      flash[:notice] = 'You have logged out successfully'
    else
      flash[:error] = "Can't log out (weren't logged in)"
    end
    redirect_to root_path
  end
end
