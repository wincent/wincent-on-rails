if ENV['RAILS_ENV']
  IRB.conf[:IRB_RC] = Proc.new do
    include FixtureReplacement
  end
end

