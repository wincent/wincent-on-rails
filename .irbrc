if File.exists?('/etc/irbrc')
  eval File.read('/etc/irbrc')
end

if Object.const_defined? :Rails
  IRB.conf[:IRB_RC] = Proc.new do
    logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = logger
    ActiveResource::Base.logger = logger
  end

  begin
    require 'rubygems'
    require 'hirb'
    Hirb.enable
  rescue LoadError
  end
end

