require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :email do |e|
  e.address { Sham.email_address }
  e.association :user
  e.verified true
end
