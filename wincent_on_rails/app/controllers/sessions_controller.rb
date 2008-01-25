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
    # NOTE: calling reset_session supposedly protects against session fixation attacks
    # but "wreaks havoc with request forgery protection" (comment in restful_authentication plugin source)
    #reset_session # must do this _before_ calling self.current_user (which manipulates the session)
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
      self.current_user = nil # deletes some info from the cookies
      flash[:notice]    = 'You have logged out successfully.'.localized
    else
      flash[:error]     = "Can't log out (weren't logged in).".localized
    end
    redirect_to home_path
  end

end
