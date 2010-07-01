require 'ostruct'

class ExceptionReporter
  def initialize app, options = {}
    @app, @options = app, options
  end

  def call env
    status, headers, body = @app.call env
    [status, headers, body]
  rescue Exception => exception
    report_exception(exception, env) if exception_reportable?(exception)
    raise exception # handled by ActionDispatch::ShowExceptions middleware
  end

private

  # Exceptions list taken from:
  #   actionpack/lib/action_dispatch/middleware/show_exceptions.rb
  @@exception_actions = {
    # requests like /foo (unknown controller, 404)
    'ActionController::RoutingError' => :default,

    # requests like /misc/foo (known controller, unknown action, 404)
    'AbstractController::ActionNotFound' => :default,

    # strictly speaking, should never get here (RecordNotFound is handled
    # by the record_not_found method in ApplicationController), but if we did
    # the default 404 page would be fine
    'ActiveRecord::RecordNotFound' => :default,

    # thrown when "optimistic locking" detects a conflict
    'ActiveRecord::StaleObjectError' => :default,

    # raised by save! and create! when validation fails
    # notify because we generally want to handle validation problems
    # via flashes and re-rendering forms
    'ActiveRecord::RecordInvalid' => :notify,

    # raised by save! and create! if a callback returns false
    # or associated model is not saved yet
    # again, notify, because we never expect to see this kind of error
    # in the normal flow of execution
    'ActiveRecord::RecordNotSaved' => :notify,

    # doesn't seem to be used at all in Rails codebase
    # seeing it is probably indicative of programmer error
    'ActionController::MethodNotAllowed' => :notify,

    # most likely a programming error
    # (hitting codepath which should never be reached)
    'ActionController::NotImplemented' => :notify,

    # raised when CSRF protection kicks in
    'ActionController::InvalidAuthenticityToken' => :default
  }

  def exception_reportable? exception
    @@exception_actions[exception.class.to_s] != :default
  end

  # TODO: may later want to rate limit exception notifications
  def report_exception exception, env
    controller = env['action_controller.instance'] ||
      OpenStruct.new(:controller_name => 'unknown', :action_name => 'unknown')
    request = ActionDispatch::Request.new(env)
    ExceptionMailer.deliver_exception_report exception, controller, request
  end
end
