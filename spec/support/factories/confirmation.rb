require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :confirmation do |c|
  c.association :email
end
