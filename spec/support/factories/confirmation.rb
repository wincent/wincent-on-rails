require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :confirmation do |c|
  c.association :email
end
