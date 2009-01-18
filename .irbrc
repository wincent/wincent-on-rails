if File.exists?('/etc/irbrc')
  eval File.read('/etc/irbrc')
end

if ENV['RAILS_ENV']
  IRB.conf[:IRB_RC] = Proc.new do
    logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = logger
    ActiveResource::Base.logger = logger

    if ENV['RAILS_ENV']  != 'production'
      include FixtureReplacement
    end
  end
end

