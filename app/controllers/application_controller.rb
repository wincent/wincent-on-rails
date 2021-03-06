class ApplicationController < ActionController::Base
  include ERB::Util     # for h()

  before_filter         :log_in_before,
                        :vary_xhr,
                        :trap_spam

  protect_from_forgery
  rescue_from           ActionController::ForbiddenError, with: :forbidden
  rescue_from           ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from           ActionController::UnknownFormat, with: :record_not_found

  # fix feed breakage caused by Rails 2.3.0 RC1
  # see: https://wincent.com/issues/1227
  layout -> (c) {
    c.request.format.try(:js?) ? false : 'application'
  }

protected

  def handle_http_status_code code, &block
    if request.xhr?
      render text: Rack::Utils::HTTP_STATUS_CODES[code], status: code
    else # HTML requests
      if block_given?
        yield
      else
        render  file:   Rails.root + 'public' + "#{code}.html",
                status: code,
                layout: false
      end
    end
  end

  # 403 error: request understood but refused, and authentication will not help
  def forbidden
    handle_http_status_code 403
  end

  # TODO: make a special 404 action that provides hints for where people could look
  def record_not_found uri = nil
    handle_http_status_code 404 do
      if uri.class != String
        # beware that in the default case uri will be an instance of ActiveRecord::RecordNotFound
        uri = root_path
      end
      flash[:error] = 'Requested %s not found' % controller_name.singularize
      redirect_to uri
    end
  end

  # Just like the default_access_options method but this time we don't exclude items awaiting moderation.
  # This is useful in places like the issue tracker where we wish to show "this item is awaiting moderation"
  # rather than just do a "record not found".
  def default_access_options_including_awaiting_moderation
    if admin?
      nil # find everything
    elsif logged_in?
      # be careful with operator precendence
      # see: https://wincent.com/issues/1546
      "(public = TRUE OR user_id = #{current_user.id})"
    else
      'public = TRUE'
    end
  end

  # TODO: replace this with proper relational algebra version
  # (although this will still work for now as where(default_access_options))
  def default_access_options
    if conditions = default_access_options_including_awaiting_moderation
      'awaiting_moderation = FALSE AND ' + conditions
    else
      'awaiting_moderation = FALSE'
    end
  end

  # Convenient access to helpers from inside controllers. Note that mixing
  # presentational code (view helpers) with controller code is generally a bad
  # idea, but there are some exceptions, such as the use of the "link_to"
  # helper to embed links in flash messages.
  def helpers
    self.class.helpers
  end

  def forbidden_flash_message
    href = login_path original_uri: request.fullpath
    log_in = helpers.link_to('Log in', href)
    'Access to the requested resource is forbidden. ' +
      "#{log_in} as an administrator to gain access."
  end

  def deliver mail
    flash[:error] = [] if flash[:error].blank?
    flash[:notice] = [] if flash[:notice].blank?
    recipient = mail.to.first
    error_msg = "An error occurred sending to #{h recipient}"
    mail.deliver_now
    flash[:notice] << "An email has been sent to #{h recipient}"
  rescue Net::SMTPFatalError
    flash[:error] << error_msg +
      ' (this looks like a permanent error; please check the address)'
  rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError
    flash[:error] << error_msg +
      ' (this looks like a temporary error; you may want to try again later)'
  rescue Exception
    flash[:error] << error_msg + ' (the cause of the error was unknown)'
  end

  def vary_xhr
    # make sure the browser knows to cache Ajax and non-Ajax variants separately
    # (avoids problems with back button etc); see:
    #
    #   https://code.google.com/p/chromium/issues/detail?id=94369
    #
    headers['Vary'] = 'X-Requested-With'
  end

  def trap_spam
    return unless request.form_data?

    if params.delete(:website_address).try(:present?)
      if request.xhr?
        # currently only comments#new.js will hit here
        respond_to do |format|
          format.html { head :ok }
          format.js {
            render text: "window.location = '#{root_path}'",
                   content_type: 'text/javascript'
          }
        end
      else
        flash[:notice] = 'Your submission has been queued for moderation'
        redirect_to root_path
      end
    end
  end
end
