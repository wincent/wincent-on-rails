class ExceptionMailer < ActionMailer::Base
  def exception_report exception, controller, request
    subject    "[ERROR] #{APP_CONFIG['host']} " +
               "#{controller.controller_name}\##{controller.action_name} " +
               "(#{exception.class}: #{exception.message})"
    recipients APP_CONFIG['admin_email']
    from       APP_CONFIG['admin_email']
    body({
      :controller => controller,
      :exception  => exception,
      :backtrace  => pretty_backtrace(exception),
      :request    => request
    })
  end

private

  def pretty_backtrace exception
    exception.backtrace.map do |line|
      "  #{line.sub(/^#{Regexp.escape(Rails.root)}/, 'RAILS_ROOT')}"
    end.join("\n")
  end
end
