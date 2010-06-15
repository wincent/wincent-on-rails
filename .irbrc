if File.exists?('/etc/irbrc')
  eval File.read('/etc/irbrc')
end

if Object.const_defined? :Rails
  IRB.conf[:IRB_RC] = Proc.new do
    logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = logger
    ActiveResource::Base.logger = logger
  end

  if Rails.env != 'production'
    require "#{Rails.root}/spec/acceptance/support/factory_girl"
  end

  begin
    require 'rubygems'
    require 'hirb'
    Hirb.enable
  rescue LoadError
  end
end

