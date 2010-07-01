class ExceptionReporter
  def initialize app, options = {}
    @app, @options = app, options
  end

  def call env
    status, headers, body = @app.call env
    [status, headers, body]
  rescue Exception => e
    rescue_action_in_public e
  end

private

  def rescue_action_in_public exception
    # From vendor/rails/actionpack/lib/action_controller/rescue.rb:
    #
    #  'ActionController::RoutingError'             => :not_found,
    #  'ActionController::UnknownAction'            => :not_found,
    #  'ActiveRecord::RecordNotFound'               => :not_found,
    #  'ActiveRecord::StaleObjectError'             => :conflict,
    #  'ActiveRecord::RecordInvalid'                => :unprocessable_entity,
    #  'ActiveRecord::RecordNotSaved'               => :unprocessable_entity,
    #  'ActionController::MethodNotAllowed'         => :method_not_allowed,
    #  'ActionController::NotImplemented'           => :not_implemented,
    #  'ActionController::InvalidAuthenticityToken' => :unprocessable_entity
    #
    # All other exceptions will result in a 500 (internal server error)
    case exception
    when ActionController::RoutingError
      # requests like /foo (unknown controller, 404)
    when ActionController::UnknownAction
      # requests like /misc/foo (known controller, unknown action, 404)
    when ActiveRecord::RecordNotFound
      # strictly speaking, should never get here (RecordNotFound is handled
      # by the record_not_found method above), but if we did the default 404
      # page would be fine
    when ActiveRecord::StaleObjectError,
         ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved,
         ActionController::MethodNotAllowed,
         ActionController::NotImplemented,
         ActionController::InvalidAuthenticityToken
      # default handling is fine for all of these
    else
      # Internal Server Error (500): these are the ones we want to know about
      # TODO: may later want to rate limit these
      ExceptionMailer.deliver_exception_report exception, self, request
    end
    raise exception
  end
end
