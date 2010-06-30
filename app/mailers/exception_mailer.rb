class ExceptionMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def exception_report exception, controller, request
    sub = "[ERROR] #{APP_CONFIG['host']} " +
          "#{controller.controller_name}\##{controller.action_name} " +
          "(#{exception.class}: #{exception.message})"

    @controller = controller
    @exception  = exception
    @backtrace  = pretty_backtrace(exception)
    @request    = request

    mail  :subject  => sub,
          :to       => APP_CONFIG['admin_email'],
          :from     => APP_CONFIG['support_email'],
          :date     => Time.now
  end

private

  def pretty_backtrace exception
    rails_root = Regexp.escape(Rails.root)
    exception.backtrace.map do |line|
      "  #{line.sub(/^#{rails_root}/, 'RAILS_ROOT')}"
    end.join("\n")
  end
end
