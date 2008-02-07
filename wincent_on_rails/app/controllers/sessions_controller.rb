# The SessionsController has only three public actions:
#   - new (display log in form)
#   - create (actually log in)
#   - destroy (log out)
class SessionsController < ApplicationController

  def new
    render
  end

  # TODO: OpenID support
  # BUG: This is only secure if connecting over HTTPS; must modify this to force SSL connections
  def create
    if self.current_user = User.authenticate(params[:login_name], params[:passphrase])
      flash[:notice]    = 'Successfully logged in.'.localized
      if original_uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to original_uri
      else
        redirect_to home_path
      end
    else
      flash[:error]     = 'Invalid login or passphrase.'.localized
      render :action => 'new'
    end
  end

  def destroy
    if self.logged_in?
      reset_session
      self.current_user = nil # delete some info from the cookies, invalidate the session key in the database, reset the session
      flash[:notice]    = 'You have logged out successfully.'.localized
    else
      flash[:error]     = "Can't log out (weren't logged in).".localized
    end
    redirect_to home_path
  end
end
