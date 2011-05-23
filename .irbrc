if File.exists?('/etc/irbrc')
  eval File.read('/etc/irbrc')
end

if Object.const_defined? :Rails
  if Rails.env != 'production'
    require 'factory_girl/syntax/sham'
    require "#{Rails.root}/spec/support/factory_girl"
    Dir["#{Rails.root}/spec/support/factories/*.rb"].each { |f| require f }
  end

  begin
    require 'rubygems'
    require 'hirb'
    Hirb.enable
  rescue LoadError
  end
end

