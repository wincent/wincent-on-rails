class ApplicationController < ActionController::Base
  #helper                    :all # include all helpers, all the time
  filter_parameter_logging  'passphrase'
  before_filter             :login_before
  before_filter             :setup_locale
  protect_from_forgery      :secret => '1b8b0816466a6f55b2a2a860c59d3ba0'
  rescue_from               ActiveRecord::RecordNotFound, :with => :record_not_found

protected

  # Before filter that sets up the current locale according to the currently-logged-in user's preferences.
  def setup_locale
    if logged_in?
      Locale.current_locale = current_user.locale
    else
      # TODO: provide a way for non-logged in users to temporarily specify a locale (cookies? hint from Accept-Languages header?)
    end
    true
  end

  def record_not_found(uri = nil)
    if uri.class != String
      # beware that in the default case uri will be an instance of ActiveRecord::RecordNotFound
      uri = home_path
    end
    flash[:error] = 'Requested %s not found'.localized % controller_name.singularize.localized
    redirect_to uri
  end

  # uncomment this method to test what remote users will see when there are errors in production mode
  # def local_request?
  #   false
  # end
end
