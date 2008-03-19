if ENV['RAILS_ENV'] && ENV['RAILS_ENV']  != 'production'
  IRB.conf[:IRB_RC] = Proc.new do
    include FixtureReplacement
  end
end

