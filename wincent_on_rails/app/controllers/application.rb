class ApplicationController < ActionController::Base
  include                   Authentication
  filter_parameter_logging  'passphrase'
  before_filter             :login_with_session_key
  before_filter             :setup_locale
  helper                    :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery      :secret => '1b8b0816466a6f55b2a2a860c59d3ba0'

  # Before filter that sets up the current locale according to the currently-logged-in user's preferences.
  def setup_locale
    if logged_in?
      Locale.current_locale = current_user.locale
    else
      # TODO: provide a way for non-logged in users to temporarily specify a locale (cookies? hint from Accept-Languages header?)
    end
    true
  end

end