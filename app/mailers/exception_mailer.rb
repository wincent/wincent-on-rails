class ExceptionMailer < ActionMailer::Base
  def exception_report exception, controller, request
    subject    "[ERROR] #{APP_CONFIG['host']} " +
               "#{controller.controller_name}\##{controller.action_name} " +
               "(#{exception.class}: #{exception.message})"
    recipients APP_CONFIG['admin_email']
    from(from_header = APP_CONFIG['support_email'])
    headers   'return-path' => from_header
    @controller = controller
    @exception  = exception
    @backtrace  = pretty_backtrace(exception)
    @request    = request
  end

private

  def pretty_backtrace exception
    rails_root = Regexp.escape(Rails.root)
    exception.backtrace.map do |line|
      "  #{line.sub(/^#{rails_root}/, 'RAILS_ROOT')}"
    end.join("\n")
  end
end
