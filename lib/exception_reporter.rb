class ExceptionReporter
  def initialize app, options = {}
    @app, @options = app, options
  end

  def call env
    status, headers, body = @app.call env
    [status, headers, body]
  rescue Exception => e
    raise e
  end
end
