if File.exists?('/etc/irbrc')
  eval File.read('/etc/irbrc')
end

if Object.const_defined? :Rails
  unless Rails.env.production?
    require "#{Rails.root}/spec/support/factory_girl"
  end
end
