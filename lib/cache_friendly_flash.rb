# Take flash messages out of the flash hash (ie. out of the session) and
# instead store them in the cookie.
#
# The user's browser unpacks the cookie and inserts the flash dynamically via
# JavaScript. (Users without JavaScript enabled miss out. This is the price of
# progress.)
#
# This allows us to freely use flash messages anywhere on the site without
# fear of them contaminating page-cached pages.
#
# We can't rely on an after_filter for this purpose because such filters are
# not guaranteed to run in all circumstances. For example, an
# ActiveRecord::RecordNotFound exception raised in a before_filter and rescued
# in a rescue_from method will prevent after filters from running, but only in
# controller specs (although it works for real requests, even when RAILS_ENV is
# 'test'); moving this to a Rack middleware eliminates this inconsistency,
# because middleware doesn't run at all in controller specs and we can simplify
# our test assertions by just querying the flash.
#
# In addition, whether or not an after_filter should always run is currently
# under discussion on the Rails tracker, and may change in the future; see:
#
#   https://rails.lighthouseapp.com/projects/8994/tickets/5648
class CacheFriendlyFlash
  def initialize app, options = {}
    @app, @options = app, options
  end

  def call env
    status, headers, body = @app.call env
    [status, headers, body]
  ensure
    request   = ActionDispatch::Request.new env
    cookies   = request.cookies
    flash     = request.flash

    flash_hash = {}
    flash.each do |key, value|
      list = listify_flash(value)
      flash_hash[key.to_sym] = list unless list.nil?
    end
    flash.clear

    # always leave cookie flash deletion up to the browser
    request.cookie_jar[:flash] = flash_hash.to_json unless flash_hash.empty?
  end

private

  # if the flash contains multiple items, turns it into an unordered list
  def listify_flash flashes
    return flashes unless flashes.kind_of?(Array)
    if flashes.empty?
      nil
    elsif flashes.length == 1
      flashes.first
    else
      items = flashes.map { |i| "<li>#{i}</li>" }
      "<ul>#{items.join}</ul>"
    end
  end
end
