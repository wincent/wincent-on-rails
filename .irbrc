if File.exists?('/etc/irbrc')
  eval File.read('/etc/irbrc')
end

if ENV['RAILS_ENV'] && ENV['RAILS_ENV']  != 'production'
  IRB.conf[:IRB_RC] = Proc.new do
    include FixtureReplacement
  end
end

