# The SessionsController has only two public actions:
#   - create (log in)
#   - destroy (log out)
class SessionsController < ApplicationController

  # TODO: OpenID support
  # BUG: This is only secure if connecting over HTTPS; must modify this to force SSL connections
  def create
    if current_user = User.authenticate(params[:login_name], params[:passphrase])
      flash[:notice]  = 'Successfully logged in.'.localized
      redirect_to home_path
    else
      flash[:error]   = 'Invalid login or passphrase.'.localized
      render :action => 'new'
    end
  end

  def destroy
    session.delete
    current_user    = nil
    flash[:notice]  = 'You have logged out successfully.'.localized
    redirect_to home_path
  end

end
