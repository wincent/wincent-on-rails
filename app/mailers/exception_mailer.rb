class ExceptionMailer < ActionMailer::Base
  default :return_path => APP_CONFIG['support_email']

  def exception_report exception, controller, request
    sub = "[ERROR] #{APP_CONFIG['host']} " +
          "#{controller.controller_name}\##{controller.action_name} " +
          "(#{exception.class}: #{exception.message})"

    @controller_name    = controller.controller_name
    @controller_action  = controller.action_name
    @exception          = exception
    @backtrace          = pretty_backtrace exception
    @request            = request
    @env                = pretty_env request.filtered_env

    mail  :subject  => sub,
          :to       => APP_CONFIG['admin_email'],
          :from     => APP_CONFIG['support_email'],
          :date     => Time.now
  end

private

  def pretty_backtrace exception
    rails_root = Regexp.escape(Rails.root.to_s)
    bundle_path = Regexp.escape(Bundler.bundle_path.to_s)
    exception.backtrace.map do |line|
      line.sub! /^#{rails_root}/, 'RAILS_ROOT'
      line.sub! /^#{bundle_path}/, 'BUNDLE_PATH'
      "  #{line}"
    end.join("\n")
  end

  def pretty_env env
    lines = env.to_yaml.split("\n")
    lines.shift # drop first line "---"
    lines.map { |line| "  #{line}" }.join("\n")
  rescue Exception => e
    # BUG: we always get here, check:
    #   actionpack-#{version}/lib/action_dispatch/middleware/templates/rescues/_request_and_response.erb
    # for how to do this
    "  [exception '#{e.message}' raised while trying to prettify env]"
  end
end
